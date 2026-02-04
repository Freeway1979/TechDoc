# Debug Web Frontend Performance

This is an excellent way to think about performance, as it splits the problem into two distinct categories:

- With Networking (Loading Performance): How fast does your site appear and become usable from a blank screen? This is all about the network request, asset downloads, and initial rendering.

- Without Networking (Runtime Performance): How fast does your site feel after it has loaded? This is about how it responds to user interactions (clicks, scrolls, typing) and animations.

The best practice is to measure Core Web Vitals (CWV), which is Google's set of metrics that captures the holistic user experience, blending both loading and runtime. The three key metrics are:

- Largest Contentful Paint (LCP): Measures loading performance.

- Interaction to Next Paint (INP): Measures runtime responsiveness.

- Cumulative Layout Shift (CLS): Measures loading visual stability.

Here is a breakdown of the best practices for measuring each category.

## 1. Performance With Networking (Loading Performance)

Your goal here is to analyze the initial page load. The primary tool is the "Network" tab in your browser's DevTools (like Chrome, Edge, or Firefox).

### Best Practices:

- Always Test in Incognito: This ensures your browser extensions don't interfere.

- Disable Cache: Check the "Disable cache" box in the Network tab to simulate a first-time visit.

- Simulate Real-World Conditions: Don't test on your fast developer machine with a high-speed connection. Use the "Throttling" dropdown and select "Fast 3G" or "Slow 3G" to see how your site performs for real users.

### How to Measure:

1. Open DevTools (F12 or Ctrl+Shift+I).
2. Go to the "Network" tab.
3. Check "Disable cache".
4. Select a throttling speed (e.g., "Fast 3G").
5. Reload your page.

### What to Look For:

- The Waterfall: This is your most important tool. It shows you what assets are loading and in what order. Look for:

    - Blocking Resources: Assets (like CSS or synchronous JS) that block other assets from downloading.

    - Long Gaps: Time where nothing is happening.

    - Late-Discoveries: Important assets (like a hero image) that are only discovered late in the loading process.

- TTFB (Time to First Byte): In the waterfall, this is the first light-green part of the bar for your main document. A high TTFB (over 600ms) means your server is slow.

- FCP and LCP Timings: The Network tab will show you vertical lines for "FCP" (First Contentful Paint) and "LCP" (Largest Contentful Paint). This tells you when your user first sees anything and when they see the most important content.

- Total Size/Resources: At the bottom, look at the total "transferred" size. If it's many megabytes (MB) for a simple page, you are sending too much.

## 2. Performance Without Networking (Runtime Performance)

Your goal here is to find JavaScript and rendering bottlenecks that make the page feel slow after it has loaded. The primary tool is the "Performance" tab in DevTools.

### Best Practices:

Isolate Actions: Don't try to measure everything at once. Record a single, specific action, such as:

Clicking a "Show More" button.

Opening a complex modal or menu.

Scrolling down a long list.

Warm-Up First: Load the page, perform the action once (e.g., open the modal), and close it. This "warms up" any cached code. Then, start your recording and perform the action again to get a more realistic measurement.

### How to Measure:

Open DevTools and go to the "Performance" tab.

Click the Record button (or Cmd/Ctrl + E).

Perform your single action (e.g., click the button that feels slow).

Click Stop.

### What to Look For:

The Flame Graph: This is the main visual. You are looking for:

Long Tasks: Any task on the "Main" thread with a red triangle in the corner. These are tasks that took longer than 50ms and blocked the browser, leading to a bad INP score.

Wide, Solid Blocks: A wide block of solid yellow means a long-running Scripting task. A wide purple block means a long Rendering (layout) task.

Main Thread Activity: Look at the "Main" timeline at the top. It should not be a solid wall of yellow (Scripting) or purple (Rendering). Lots of idle (gray) time is healthy.

FPS (Frames Per Second): Look at the "Frames" row. If you see red blocks, it means your animation or scroll stuttered and dropped frames. You want a consistent, high (60 FPS) green bar.

"Performance Monitor" Tab: For a real-time view, open the DevTools "Command Menu" (Cmd/Ctrl + Shift + P), type "Show Performance Monitor," and press Enter. You can watch your CPU usage, JS heap size, and Layouts/sec in real-time as you interact with your site.

### 3. The Ultimate Best Practice: Combining Both

The final and most important practice is to combine these two methods and use Real User Monitoring (RUM).

Lab Data (What you just did): Running tests on your machine using DevTools. This is great for diagnosing problems.

Field Data (RUM): Collecting performance data from all your actual users on their real devices and networks. This is essential for finding problems.

Tools for Field Data (RUM):

PageSpeed Insights: This is the easiest. It pulls data from Google's Chrome User Experience Report (CrUX) and shows you your real-world Core Web Vitals scores over the last 28 days.

Vercel Analytics, Sentry, New Relic, Datadog: These are professional services that you add to your site to collect RUM data from every user, giving you detailed dashboards on your LCP, INP, and CLS scores.

### Summary: With vs. Without Networking

With Networking (Loading)	Without Networking (Runtime)
Question	"How fast does my page load?"	"How fast does my page feel?"
Core Metric	LCP (Largest Contentful Paint)	INP (Interaction to Next Paint)
Primary Tool	DevTools "Network" Tab	DevTools "Performance" Tab
Key Visual	Network Waterfall	Performance Flame Graph
Goal	Small assets, non-blocking, fast server	No long tasks, 60 FPS, fast event handlers