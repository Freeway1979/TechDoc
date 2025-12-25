over-fetching vs under-fetching
REST API design, often called the **"over-fetching"** vs. **"under-fetching"** dilemma.

* **Under-fetching:** When the client has to make multiple API requests to gather all the necessary data for a single screen (e.g., fetching a `Post`, then fetching `Comments` separately, then fetching `AuthorDetails` separately). This is inefficient due to high latency.
* **Over-fetching:** When the API sends a huge payload containing fields the frontend doesn't need, wasting bandwidth and time (e.g., sending the entire 1MB user biography when the frontend only needed the `firstName` and `avatarUrl`).

The best practice is to design a set of options that allows the client (the frontend) to explicitly control the scope and depth of the data returned by the server.

---

## 1. The Primary Solution: Query Parameters

The standard and most recommended way to achieve balance in a REST API is by using query parameters to allow the client to request specific fields or embed related resources.

### A. The `fields` Parameter (Filtering)

This allows the client to explicitly ask for a subset of fields, solving the **over-fetching** problem. If this parameter is missing, the API should return a sensible default.

| Client Request | Server Action |
| :--- | :--- |
| `GET /users/123` | Returns the **full** user object (Name, Email, Bio, Preferences, etc.). |
| `GET /users/123?fields=name,email,avatarUrl` | Returns only those three specified fields. |

**Implementation Strategy:**

1.  The backend should parse the comma-separated `fields` string.
2.  Use that list to construct the database query (e.g., a `SELECT name, email, avatarUrl FROM users...`). This makes the query faster at the database level, too.
3.  Filter the resulting object before serialization to JSON.

### B. The `embed` or `include` Parameter (Nesting/Deepening)

This allows the client to request that related resources be **nested** directly in the response, solving the **under-fetching** problem.

| Client Request | Server Action |
| :--- | :--- |
| `GET /posts/456` | Returns the `Post` object, typically with only the `authorId`. |
| `GET /posts/456?include=author,comments` | Returns the `Post` object with the full `author` object and the array of `comments` nested inside it. |

**Implementation Strategy:**

1.  The backend parses the `include` parameter.
2.  The original request executes.
3.  The server then executes the necessary lookups (e.g., `SELECT * FROM authors WHERE id = post.authorId`).
4.  The server embeds the resulting data into the main post object before returning.

---

## 2. Advanced Solution: GraphQL (If Complexity Allows)

If your application has highly complex relationships or rapidly changing data requirements where filtering parameters are too restrictive, **GraphQL** is the best architectural solution.

* **How it works:** GraphQL shifts control entirely to the client. The client sends a specific **query** defining the exact data structure and fields it needs.
* **No Over/Under-Fetching:** The server guarantees that it will return **exactly** the data structure requested, no more and no less.

| REST vs. GraphQL | REST | GraphQL |
| :--- | :--- | :--- |
| **Request Method** | Multiple endpoints (e.g., `/users/1`, `/users/1/posts`) | Single endpoint (e.g., `/graphql`) |
| **Data Contract** | Fixed response structure | Client dictates structure |
| **Example Request** | `GET /users/1?include=posts&fields=name,posts.title` | `query { user(id: 1) { name posts { title } } }` |

**When to use it:** For high-volume applications where optimizing network traffic and flexibility is paramount (e.g., large-scale social media apps).

---

## 3. Alternative for Fixed Data Requirements: Fixed Views

If you have specific UI pages that always need a particular data set, you can create a dedicated endpoint that serves only that data. This is simpler to implement than `fields` or `include` parameters but is less flexible.

| Endpoint | Purpose | Example Response |
| :--- | :--- | :--- |
| `GET /users/123` | Full Resource | `{ id: 123, name: "A", bio: "long text..." }` |
| `GET /users/123/list-view` | Optimized for a List | `{ id: 123, name: "A", avatarUrl: "..." }` |

This trades implementation flexibility (you have to build a new endpoint for every view) for stability and performance guarantees, as the backend knows exactly what data the client expects.