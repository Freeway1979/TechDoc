Upgrading from Ant Design 3.x to 4.x is a significant major version bump. The two biggest changes you will face are the **Icon system** (for smaller bundle sizes) and a complete rewrite of the **Form component** (for better performance).

Ant Design provides tools to automate much of this. Follow this step-by-step guide to smooth out the process.

### **Phase 1: Preparation & Automated Migration**

The Ant Design team provides a `codemod` tool that can automatically refactor about 70-80% of your code.

**1. Upgrade Dependencies**
First, ensure you are running React 16.12.0+ (Hooks support is required for v4). Then, install antd v4 and the compatibility package.

```bash
npm install antd@^4.0.0 @ant-design/compatible @ant-design/icons
# or
yarn add antd@^4.0.0 @ant-design/compatible @ant-design/icons
```

**2. Run the Migration Tool (Codemod)**
This tool traverses your project and updates imports and basic syntax. Run it on your source folder (e.g., `src`):

```bash
# Run the codemod directly via npx
npx -p @ant-design/codemod-v4 antd4-codemod src
```

*Select the options to upgrade everything when prompted.*

### **Phase 2: Handling Key Breaking Changes**

After the codemod runs, you will likely still have errors. Address them in this order:

#### **1. The New Icon System (Major Change)**

In v3, icons were strings (e.g., `icon="smile"`). In v4, they are React components. This allows "Tree Shaking" so you don't bundle every icon icon existing.

  * **Old (v3):**
    ```jsx
    <Icon type="smile" />
    <Button icon="search">Search</Button>
    ```
  * **New (v4):**
    ```jsx
    import { SmileOutlined, SearchOutlined } from '@ant-design/icons';

    <SmileOutlined />
    <Button icon={<SearchOutlined />}>Search</Button>
    ```
  * **Action:** If you used dynamic icons (e.g., `icon={someString}`), you will need to create a mapping object or manually import the specific icons you need.

#### **2. Form Component Rewrite (Critical Change)**

The `Form` component was rewritten to improve performance. `Form.create()` and `getFieldDecorator` are **removed**.

  * **Old (v3):**

    ```jsx
    const MyForm = ({ form }) => {
      const { getFieldDecorator } = form;
      return (
        <Form onSubmit={handleSubmit}>
          <Form.Item>
            {getFieldDecorator('username', {
              rules: [{ required: true }],
            })(<Input />)}
          </Form.Item>
        </Form>
      );
    };
    export default Form.create()(MyForm);
    ```

  * **New (v4):**

    ```jsx
    const MyForm = () => {
      // 1. Use the hook instead of props
      const [form] = Form.useForm(); 
      
      const onFinish = (values) => {
        console.log(values);
      };

      return (
        // 2. onFinish replaces onSubmit. No need for e.preventDefault()
        <Form form={form} onFinish={onFinish}>
          {/* 3. 'name' and 'rules' are now props of Form.Item */}
          <Form.Item name="username" rules={[{ required: true }]}>
             <Input />
          </Form.Item>
        </Form>
      );
    };
    ```

**Quick Fix Strategy:**
The codemod often changes old Forms to use the `Form` from `@ant-design/compatible`. This keeps your v3 code working while using the v4 library.

  * **Short term:** Keep using `import { Form } from '@ant-design/compatible';`
  * **Long term:** Rewrite them to the new v4 `Form` API for better performance.

#### **3. Grid System Changes**

The `Row` and `Col` components switched to using `flex` layout by default.

  * **Impact:** If you were doing custom CSS overrides on rows/cols, they might break.
  * **Fix:** Check your layouts. You usually don't need to change code, but you might need to adjust custom CSS margins.

### **Phase 3: Other Notable Changes**

| Component | Change |
| :--- | :--- |
| **LocaleProvider** | Deprecated. Use `<ConfigProvider locale={...}>` instead. |
| **Modal / Drawer** | `visible` prop is renamed to `open`. (The codemod usually handles this). |
| **DatePicker** | Specific components like `<MonthPicker>` are removed. Use `<DatePicker picker="month" />`. |
| **Mention** | Removed from core. Use `Mentions` (note the 's') or import the old one from `@ant-design/compatible`. |

### **Common Pitfalls & "Gotchas"**

1.  **`initialValue` in Forms:**
    In v4, `initialValue` is a prop on `Form.Item` (or `initialValues` object on the `Form` itself). It **only works on the initial render**. If you need to update form values dynamically after load (e.g., after fetching data), you **must** use `form.setFieldsValue(data)`, not props.

2.  **`ref` usage:**
    `Form.create()` wrapped your component, so you often used `wrappedComponentRef`. In v4, since there is no wrapper, you can just use standard React `ref`.

3.  **CSS Imports:**
    If you import CSS directly, the path might have changed slightly, though the standard `import 'antd/dist/antd.css';` usually remains valid (until v5).

### **Summary Checklist**

1.  [ ] Upgrade `package.json` dependencies.
2.  [ ] Run `npx -p @ant-design/codemod-v4 antd4-codemod src`.
3.  [ ] Fix any broken Icons (look for errors about `Icon` not being found).
4.  [ ] Verify Forms are working (either via `@ant-design/compatible` or rewritten).
5.  [ ] Check for layout regressions (Row/Col flex behavior).

### **Next Step**

Would you like to see a specific code example of **migrating a complex Form with validation** from v3 to v4?

Here is a side-by-side comparison of migrating a generic "User Profile" form that includes validation and a select dropdown.

### **The Scenario**

We have a form with:

1.  **Username:** Required field.
2.  **Role:** A dropdown selection.
3.  **Submission:** Logs data to the console.

-----

### **1. The "Before" Code (Ant Design v3)**

  * **Pattern:** Higher-Order Component (`Form.create()`).
  * **State Access:** Via `this.props.form`.
  * **Validation:** Inline inside `getFieldDecorator`.

<!-- end list -->

```jsx
import React from 'react';
import { Form, Input, Button, Select } from 'antd';

const { Option } = Select;

class UserProfileForm extends React.Component {
  handleSubmit = e => {
    e.preventDefault(); // 1. Manually prevent default submission
    
    // 2. validateFields is callback-based
    this.props.form.validateFields((err, values) => {
      if (!err) {
        console.log('Received values of form: ', values);
      }
    });
  };

  render() {
    // 3. Destructure getFieldDecorator from props
    const { getFieldDecorator } = this.props.form;

    return (
      <Form onSubmit={this.handleSubmit}>
        <Form.Item label="Username">
          {/* 4. getFieldDecorator wraps the input */}
          {getFieldDecorator('username', {
            rules: [{ required: true, message: 'Please input your username!' }],
            initialValue: 'JohnDoe' 
          })(
            <Input placeholder="Username" />
          )}
        </Form.Item>

        <Form.Item label="Role">
          {getFieldDecorator('role', {
            rules: [{ required: true, message: 'Please select a role!' }],
          })(
            <Select placeholder="Select a role">
              <Option value="admin">Admin</Option>
              <Option value="guest">Guest</Option>
            </Select>
          )}
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit">
            Save
          </Button>
        </Form.Item>
      </Form>
    );
  }
}

// 5. Wrap the component
export default Form.create({ name: 'user_profile' })(UserProfileForm);
```

-----

### **2. The "After" Code (Ant Design v4)**

  * **Pattern:** React Hooks (`Form.useForm`).
  * **State Access:** Internal form instance.
  * **Validation:** Props on `<Form.Item>`.

<!-- end list -->

```jsx
import React, { useEffect } from 'react';
import { Form, Input, Button, Select } from 'antd';

const { Option } = Select;

const UserProfileForm = () => {
  // 1. Create form instance via Hook
  const [form] = Form.useForm();

  // 2. onFinish handles successful validation automatically
  const onFinish = (values) => {
    console.log('Received values of form: ', values);
  };

  const onFinishFailed = (errorInfo) => {
    console.log('Failed:', errorInfo);
  };

  // Optional: How to set dynamic values (replaces initialValue logic for async data)
  useEffect(() => {
    form.setFieldsValue({ username: 'JohnDoe' });
  }, [form]);

  return (
    <Form
      form={form} // Bind the instance
      layout="vertical"
      name="user_profile"
      initialValues={{ role: 'guest' }} // 3. Global initial values
      onFinish={onFinish} // 4. No e.preventDefault needed
      onFinishFailed={onFinishFailed}
    >
      {/* 5. Validation rules move to the Item props */}
      <Form.Item
        label="Username"
        name="username"
        rules={[{ required: true, message: 'Please input your username!' }]}
      >
        <Input placeholder="Username" />
      </Form.Item>

      <Form.Item
        label="Role"
        name="role"
        rules={[{ required: true, message: 'Please select a role!' }]}
      >
        <Select placeholder="Select a role">
          <Option value="admin">Admin</Option>
          <Option value="guest">Guest</Option>
        </Select>
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit">
          Save
        </Button>
      </Form.Item>
    </Form>
  );
};

export default UserProfileForm;
```

-----

### **Key Migration Concepts**

| Feature | v3 (`getFieldDecorator`) | v4 (`Form.Item` props) |
| :--- | :--- | :--- |
| **Field Binding** | `getFieldDecorator('name', ...)(<Input />)` | `<Form.Item name="name"><Input /></Form.Item>` |
| **Initial Values** | Inside `getFieldDecorator` options | `initialValues` prop on `<Form>` or `<Form.Item>` |
| **Submission** | `onSubmit={this.handleSubmit}` | `onFinish={onFinish}` |
| **Validation** | `validateFields((err, values) => ...)` | `onFinish` (success) / `onFinishFailed` (error) |
| **Dynamic Set** | `this.props.form.setFieldsValue` | `form.setFieldsValue` (via `useForm` hook) |

### **The "Gotcha": Initial Values vs. Asynchronous Data**

In v3, you often passed `initialValue` inside `render()`. If props changed, the form updated.

In v4, **`initialValues` on the Form only works on the FIRST render.** If you are fetching data from an API (e.g., loading a user profile to edit), `initialValues` will not update the form if the data arrives after the first render.

**The Fix:**
You must use `useEffect` to push data into the form once it loads:

```jsx
useEffect(() => {
  // When 'userData' comes from your API
  form.setFieldsValue(userData);
}, [userData, form]);
```

### **Next Step**

Now that the logic is updated, you may encounter styling issues. Would you like me to explain how the **Grid System** props (`labelCol` / `wrapperCol`) work on the new `Form` vs `Form.Item` in v4?

In Ant Design, the layout of forms relies on a 24-column grid system. Understanding `labelCol` and `wrapperCol` is crucial because if you get them wrong, your labels will either be squashed or your input fields will push off the screen.

### **The Concept: The 24-Column Grid**

Every `Form.Item` is treated as a row spanning 24 grid units. You split these units between the **Label** (text) and the **Wrapper** (input field).

  * **`labelCol`**: The width of the text label (e.g., "Username").
  * **`wrapperCol`**: The width of the input area (e.g., the text box).

-----

### **The Upgrade: Inheritance (v4 vs. v3)**

This is the biggest quality-of-life improvement in v4 styling.

  * **In v3:** You often had to repeat `labelCol` and `wrapperCol` props on **every single** `Form.Item`.
  * **In v4:** You set them once on the parent `<Form>` component. All items inside inherit these settings automatically. You only define them on an Item if you need to *override* the default.

### **Code Example: Standard Horizontal Layout**

Here is how to set up a clean alignment where labels take up 1/3 (8 cols) and inputs take up 2/3 (16 cols).

```jsx
import { Form, Input, Button } from 'antd';

const Demo = () => {
  // Define the layout configuration object
  const layout = {
    labelCol: { span: 8 },
    wrapperCol: { span: 16 },
  };

  // Define a separate layout for the submit button (to align it with inputs)
  const tailLayout = {
    wrapperCol: { offset: 8, span: 16 },
  };

  return (
    <Form
      {...layout} // 1. Apply global layout here
      name="basic"
    >
      {/* This Item inherits labelCol={span: 8} and wrapperCol={span: 16} */}
      <Form.Item label="Username" name="username">
        <Input />
      </Form.Item>

      {/* This Item inherits the same layout */}
      <Form.Item label="Password" name="password">
        <Input.Password />
      </Form.Item>

      {/* 2. Override layout for the button so it aligns with the inputs, not the labels */}
      <Form.Item {...tailLayout}>
        <Button type="primary" htmlType="submit">
          Submit
        </Button>
      </Form.Item>
    </Form>
  );
};
```

### **Common Layout Scenarios**

#### **1. The "Full Width" Exception**

Sometimes you want a specific field (like a "Comments" text area) to take up the full width, or have the label on top, even inside a horizontal form.

To do this, you override the props on that specific `Form.Item`:

```jsx
<Form.Item 
  label="Comments" 
  name="comments"
  labelCol={{ span: 24 }}   // Force label to take full width (stacks it)
  wrapperCol={{ span: 24 }} // Force input to take full width
>
  <Input.TextArea />
</Form.Item>
```

#### **2. Vertical Layout (Mobile Friendly)**

If you want to avoid calculating columns entirely, simply use `layout="vertical"` on the `<Form>`.

```jsx
<Form layout="vertical">
   {/* labelCol and wrapperCol are ignored; Label stacks on top of Input */}
   <Form.Item label="Username" name="username">
     <Input />
   </Form.Item>
</Form>
```

### **Responsive Layouts**

Both v3 and v4 support responsive objects. If you want the form to look different on mobile vs. desktop:

```jsx
const layout = {
  labelCol: { 
    xs: { span: 24 }, // Mobile: Label takes full width (stacks)
    sm: { span: 8 },  // Tablet/Desktop: Label takes 8 cols
  },
  wrapperCol: { 
    xs: { span: 24 }, // Mobile: Input takes full width
    sm: { span: 16 }, // Tablet/Desktop: Input takes 16 cols
  },
};

<Form {...layout}>...</Form>
```

### **Next Step**

A common issue after upgrading is **Dependency Validation** (e.g., "Confirm Password" must match "Password", or "End Date" must be after "Start Date").

Would you like to see how to implement **field dependencies** using the new `dependencies` prop in v4?

In Ant Design v4, handling fields that depend on each other (like "Confirm Password" or linked Date Pickers) is much cleaner than in v3. You no longer need to manually trigger validation callbacks.

Instead, you use the **`dependencies`** prop.

### **The Concept**

When you add `dependencies={['otherField']}` to a `Form.Item`:

1.  It tells Ant Design: *"If 'otherField' changes, re-run the validation rules for this field too."*
2.  It ensures the validation logic has access to the *current* value of that dependency.

-----

### **Example 1: "Confirm Password"**

This is the classic use case. If the user changes the original "Password", the "Confirm Password" field needs to re-check if it still matches.

```jsx
import React from 'react';
import { Form, Input, Button } from 'antd';

const RegistrationForm = () => {
  const [form] = Form.useForm();

  const onFinish = (values) => {
    console.log('Received values:', values);
  };

  return (
    <Form form={form} name="register" onFinish={onFinish} scrollToFirstError>
      
      {/* 1. Primary Password Field */}
      <Form.Item
        name="password"
        label="Password"
        rules={[
          { required: true, message: 'Please input your password!' },
        ]}
        hasFeedback
      >
        <Input.Password />
      </Form.Item>

      {/* 2. Confirm Password Field */}
      <Form.Item
        name="confirm"
        label="Confirm Password"
        dependencies={['password']} // <--- TRIGGER: Re-validate this field when 'password' changes
        hasFeedback
        rules={[
          { required: true, message: 'Please confirm your password!' },
          
          // 3. Custom Validator
          ({ getFieldValue }) => ({
            validator(_, value) {
              // If empty or matches, resolve (valid)
              if (!value || getFieldValue('password') === value) {
                return Promise.resolve();
              }
              // Otherwise reject (invalid)
              return Promise.reject(new Error('The two passwords that you entered do not match!'));
            },
          }),
        ]}
      >
        <Input.Password />
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit">Register</Button>
      </Form.Item>
    </Form>
  );
};
```

-----

### **Example 2: Conditional Rendering (Advanced)**

Sometimes a dependency isn't just about *validation*, but about *visibility*.

  * *Scenario:* If a user selects "Other" in a dropdown, show a text input.

In v4, you use the `<Form.Item noStyle shouldUpdate>` pattern (often called a "Render Prop"). This replaces the old v3 hack of `getFieldValue` inside the render method.

```jsx
<Form.Item name="topic" label="Topic">
  <Select>
    <Option value="issue">Report an Issue</Option>
    <Option value="other">Other</Option>
  </Select>
</Form.Item>

{/* 1. Wrap the conditional logic in a noStyle Item */}
<Form.Item
  noStyle
  shouldUpdate={(prevValues, currentValues) => prevValues.topic !== currentValues.topic}
>
  {({ getFieldValue }) => 
    // 2. Check the value inside the function
    getFieldValue('topic') === 'other' ? (
      <Form.Item 
        name="other_topic" 
        label="Please specify" 
        rules={[{ required: true }]}
      >
        <Input />
      </Form.Item>
    ) : null
  }
</Form.Item>
```

### **Summary of `dependencies` vs `shouldUpdate`**

| Feature | Use `dependencies` | Use `shouldUpdate` |
| :--- | :--- | :--- |
| **Purpose** | **Validation** logic. (e.g., A \> B) | **Rendering** logic. (e.g., Show/Hide field) |
| **Behavior** | Triggers re-validation of rules. | Triggers a re-render of the component area. |
| **Complexity** | Simple prop on `<Form.Item>`. | Requires a function child (Render Prop). |

### **Next Step**

You have the form structure, layout, and logic down. The final piece of a production-ready form is often **Resetting** or **Populating** data programmatically.

Would you like to see how to properly use `form.resetFields()` vs `form.setFieldsValue()`? (This is often a source of bugs when closing/re-opening Modals).

Handling form state in Modals is the number one source of bugs in Ant Design. The confusion usually stems from understanding the difference between "clearing" a form and "resetting" it to its initial state.

Here is how to manage `setFieldsValue` vs `resetFields` effectively.

### **The Core Difference**

| Method | Behavior | Use Case |
| :--- | :--- | :--- |
| **`form.setFieldsValue({ key: value })`** | **Updates** specific fields with new data. It does *not* touch fields you don't mention. | Loading data from an API for "Edit Mode". |
| **`form.resetFields()`** | **Restores** fields to the `initialValues` defined on the `<Form>`. If no initial values exist, it clears them. | Clicking "Cancel", "Clear", or switching to "Create Mode". |

-----

### **The Common "Modal Trap"**

**The Scenario:**

1.  You click **"Edit User A"**. The Modal opens, you call `setFieldsValue(UserA)`.
2.  You close the Modal.
3.  You click **"Create New User"**. The Modal opens.
4.  **Bug:** The form still contains "User A's" data\!

**Why?**
The `<Form>` component inside the Modal was never unmounted (destroyed). It just became invisible. Therefore, its internal state persisted.

-----

### **Solution 1: The "Nuclear" Option (`destroyOnClose`)**

The easiest fix is to tell the Modal to completely kill its children when it closes.

```jsx
<Modal
  title="User Form"
  open={isModalVisible}
  onCancel={handleCancel}
  destroyOnClose={true} // <--- The Magic Prop
>
  <MyForm /> 
</Modal>
```

  * **Pros:** Simplest implementation. Guarantees a fresh form every time.
  * **Cons:** You lose transition animations (the form snaps out of existence). It can be slightly slower if the form is massive.

-----

### **Solution 2: The "Controlled" Option (`useEffect`)**

This is the professional approach. You manually watch for the Modal opening and decide whether to **Fill** (Edit) or **Reset** (Create).

```jsx
import React, { useEffect } from 'react';
import { Modal, Form, Input } from 'antd';

const UserModal = ({ visible, onCreate, onCancel, editingUser }) => {
  const [form] = Form.useForm();

  // Watch for changes in visibility or the data being edited
  useEffect(() => {
    if (visible) {
      if (editingUser) {
        // Mode: EDIT -> Fill the form
        form.setFieldsValue(editingUser);
      } else {
        // Mode: CREATE -> Reset to initial values (empty)
        form.resetFields();
      }
    }
  }, [visible, editingUser, form]);

  const onOk = () => {
    form.validateFields().then((values) => {
      onCreate(values);
      form.resetFields(); // Optional: Clear on success
    }).catch((info) => {
      console.log('Validate Failed:', info);
    });
  };

  return (
    <Modal
      open={visible}
      title={editingUser ? "Edit User" : "Create User"}
      onOk={onOk}
      onCancel={onCancel}
    >
      <Form form={form} layout="vertical" name="user_form">
        <Form.Item
          name="name"
          label="Name"
          rules={[{ required: true }]}
        >
          <Input />
        </Form.Item>
        <Form.Item name="email" label="Email">
          <Input />
        </Form.Item>
      </Form>
    </Modal>
  );
};
```

### **A Critical Warning: `resetFields` vs `initialValues`**

`resetFields()` does **not** mean "make everything blank." It means "go back to `initialValues`."

If you have this:

```jsx
<Form form={form} initialValues={{ role: 'admin' }}>
```

When you call `form.resetFields()`, the `role` field will revert to `'admin'`, not `undefined`. This is usually what you want, but it can catch developers off guard if they expect the form to be completely empty.

### **Next Step**

We have covered the Migration, Layouts, Validation, and State Management.

The final advanced topic is creating **Custom Form Controls**. For example, if you need a specialized "Price Input" that isn't in Ant Design but needs to work with `Form.Item` validation.

Would you like to see how to build a custom component that hooks into the Ant Design v4 Form system?

Creating a custom form control in Ant Design v4 is surprisingly simple once you understand the "Contract."

To make any component work with `<Form.Item>`, your component just needs to follow **The Golden Rule of Controlled Components**:

> Your component must accept a **`value`** prop and trigger an **`onChange`** callback.

Ant Design's `Form.Item` automatically injects these two props into its direct child.

-----

### **The Scenario: A "Price Input" Component**

We want a single form field that returns an object: `{ number: 100, currency: 'USD' }`.
It consists of two inputs (a dropdown and a number field) visually merged into one.

### **Step 1: Build the Custom Component**

We need to build a component that handles the internal logic of merging the currency and the number, but relies on the parent form for its state.

```jsx
import React from 'react';
import { Input, Select, Form } from 'antd';

const { Option } = Select;

// 1. Destructure value and onChange (automatically passed by Form.Item)
const PriceInput = ({ value = {}, onChange }) => {
  
  const [number, setNumber] = React.useState(0);
  const [currency, setCurrency] = React.useState('USD');

  // Sync internal state if the form changes the value externally (e.g. initialValues)
  React.useEffect(() => {
    if (value.number) setNumber(value.number);
    if (value.currency) setCurrency(value.currency);
  }, [value]);

  // 2. The trigger function: Merges old data with new data and calls onChange
  const triggerChange = (changedValue) => {
    // Call the parent's onChange with the full object
    onChange({
      number,
      currency,
      ...changedValue,
    });
  };

  const onNumberChange = (e) => {
    const newNumber = parseInt(e.target.value || 0, 10);
    setNumber(newNumber);
    triggerChange({ number: newNumber });
  };

  const onCurrencyChange = (newCurrency) => {
    setCurrency(newCurrency);
    triggerChange({ currency: newCurrency });
  };

  return (
    <span>
      <Input
        type="text"
        value={value.number || number}
        onChange={onNumberChange}
        style={{ width: 100 }}
      />
      <Select
        value={value.currency || currency}
        style={{ width: 80, margin: '0 8px' }}
        onChange={onCurrencyChange}
      >
        <Option value="rmb">RMB</Option>
        <Option value="usd">USD</Option>
      </Select>
    </span>
  );
};
```

-----

### **Step 2: Use it in the Form**

Now you can use `<PriceInput />` exactly like you would use a standard `<Input />`.

You also need a **Custom Validator** because the `required: true` rule checks if the value is not null, but our value is an object. We need to check if `value.number` is greater than zero.

```jsx
const Demo = () => {
  const onFinish = (values) => {
    // values.price will be { number: 100, currency: 'USD' }
    console.log('Received values from form: ', values);
  };

  // 3. Custom Validator for the object
  const checkPrice = (_, value) => {
    if (value.number > 0) {
      return Promise.resolve();
    }
    return Promise.reject(new Error('Price must be greater than zero!'));
  };

  return (
    <Form
      name="customized_form_controls"
      layout="inline"
      onFinish={onFinish}
      initialValues={{
        price: { number: 0, currency: 'rmb' }, // 4. Set initial state here
      }}
    >
      <Form.Item
        name="price"
        label="Price"
        // 5. Apply the custom validator
        rules={[{ validator: checkPrice }]}
      >
        {/* Form.Item injects value and onChange here automatically */}
        <PriceInput />
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit">
          Submit
        </Button>
      </Form.Item>
    </Form>
  );
};
```

### **Common Pitfalls**

1.  **Missing `value` in Props:**
    If you forget to destructure `value` in your custom component props, the Form won't be able to clear or set the input. It will become "Uncontrolled."

2.  **`onChange` Signature:**
    Standard HTML inputs return an event object (`e`). Custom Ant Design components usually expect the raw value (string, number, or object). Ensure your `triggerChange` sends the **data**, not the event (unless you want to parse the event in the parent, which is messy).

3.  **Styles:**
    `Form.Item` does not automatically style your component. If your custom component is just a `div`, it might look weird. You often need to pass `style` or `className` props through to the root element of your custom component.

### **Final Summary of the Series**

You are now equipped to handle a full Ant Design v4 migration:

1.  **Migration:** You know how to use the `codemod` and handle the Icon/compatible package changes.
2.  **Layouts:** You can handle the 24-column grid inheritance.
3.  **Logic:** You can use `dependencies` for complex validation.
4.  **State:** You know how to safely reset forms in Modals.
5.  **Customization:** You can build your own complex inputs.

### **Next Step**

This concludes the core guide for upgrading Ant Design 3 to 4. Would you like me to bundle these code snippets into a single **"Cheat Sheet" Markdown file** that you can copy-paste for your team?

Here is your complete **Ant Design v3 to v4 Migration Cheat Sheet**. You can copy this entire block and save it as `ANTD_MIGRATION_GUIDE.md` for your team.

-----

# Ant Design v3 to v4 Migration Cheat Sheet

## 1\. Installation & Automation

**Step 1: Install Dependencies**
React 16.12+ is required. You need the compatibility package for a smooth transition.

```bash
npm install antd@^4.0.0 @ant-design/compatible @ant-design/icons
```

**Step 2: Run the Codemod**
This automates \~70% of the syntax changes (imports, simple props).

```bash
# Run on your source folder
npx -p @ant-design/codemod-v4 antd4-codemod src
```

-----

## 2\. Icons (Breaking Change)

Icons are no longer strings; they are modular React components to support tree-shaking.

| Feature | v3 (Old) | v4 (New) |
| :--- | :--- | :--- |
| **Import** | `import { Icon } from 'antd';` | `import { SmileOutlined } from '@ant-design/icons';` |
| **Usage** | `<Icon type="smile" />` | `<SmileOutlined />` |
| **Button** | `<Button icon="search">` | `<Button icon={<SearchOutlined />}>` |

-----

## 3\. Forms: The Core Architecture

The `Form` component is completely rewritten. It now stores its own state.

**Key Changes:**

1.  **No HOC:** `Form.create()` is gone.
2.  **No getFieldDecorator:** Validation rules move to `Form.Item`.
3.  **Hooks:** Use `const [form] = Form.useForm()` to control the form instance.

### **Side-by-Side Comparison**

**v3 (Legacy)**

```jsx
const MyForm = ({ form }) => {
  const { getFieldDecorator } = form; // From props
  const handleSubmit = (e) => {
    e.preventDefault();
    form.validateFields((err, values) => { /* ... */ });
  }
  
  return (
    <Form onSubmit={handleSubmit}>
      <Form.Item>
        {getFieldDecorator('username', { 
           rules: [{ required: true }] 
        })(<Input />)}
      </Form.Item>
    </Form>
  );
};
export default Form.create()(MyForm);
```

**v4 (Modern)**

```jsx
const MyForm = () => {
  const [form] = Form.useForm(); // Hook
  
  const onFinish = (values) => {
    // Validated automatically
    console.log(values); 
  };

  return (
    <Form form={form} onFinish={onFinish}>
      <Form.Item name="username" rules={[{ required: true }]}>
        <Input />
      </Form.Item>
    </Form>
  );
};
```

-----

## 4\. Layout & Grid

In v4, `Form.Item` inherits layout props from the parent `Form`. You don't need to repeat them.

```jsx
const layout = {
  labelCol: { span: 8 },
  wrapperCol: { span: 16 },
};

<Form {...layout}>
  {/* Inherits 8/16 split */}
  <Form.Item label="Username" name="user"><Input /></Form.Item>
  
  {/* Override specific item to be full width */}
  <Form.Item 
    label="Bio" 
    name="bio" 
    labelCol={{ span: 24 }} 
    wrapperCol={{ span: 24 }}
  >
    <Input.TextArea />
  </Form.Item>
</Form>
```

-----

## 5\. Complex Validation (Dependencies)

Do not use `validator` callbacks to check other fields. Use `dependencies` to trigger re-validation.

**Example: Confirm Password**

```jsx
<Form.Item
  name="confirm"
  dependencies={['password']} // Re-runs rules when 'password' changes
  rules={[
    { required: true },
    ({ getFieldValue }) => ({
      validator(_, value) {
        if (!value || getFieldValue('password') === value) {
          return Promise.resolve();
        }
        return Promise.reject('Passwords do not match!');
      },
    }),
  ]}
>
  <Input.Password />
</Form.Item>
```

-----

## 6\. Modals & Resetting State

`initialValues` only work on the **first render**. To handle "Edit" vs "Create" in a Modal, use `useEffect`.

```jsx
const UserModal = ({ visible, user, onCancel }) => {
  const [form] = Form.useForm();

  // Watch for Modal opening
  useEffect(() => {
    if (visible) {
      if (user) {
        form.setFieldsValue(user); // Edit Mode: Fill data
      } else {
        form.resetFields(); // Create Mode: Clear to initial state
      }
    }
  }, [visible, user, form]);

  return (
    <Modal open={visible} onCancel={onCancel} onOk={() => form.submit()}>
      <Form form={form} onFinish={...}>...</Form>
    </Modal>
  );
};
```

-----

## 7\. Custom Form Controls

To make a custom component work inside `<Form.Item>`, it must accept `value` and emit `onChange`.

```jsx
// 1. The Component
const PriceInput = ({ value = {}, onChange }) => {
  const triggerChange = (changedValue) => {
    // Merge old value with new change
    onChange({ ...value, ...changedValue });
  };
  
  return (
    <span>
      <Input 
        value={value.number} 
        onChange={e => triggerChange({ number: e.target.value })} 
      />
      <Select 
        value={value.currency} 
        onChange={c => triggerChange({ currency: c })} 
      />
    </span>
  );
};

// 2. The Usage
<Form.Item name="price">
  <PriceInput /> 
</Form.Item>
```

-----

### **Next Step**

You are all set\! If you run into weird CSS issues where rows are misaligned, check if you have any global CSS targeting `.ant-row` or `.ant-col`, as v4 changed these from `float` to `flex` layouts.

Good luck with the migration\!