The reason you're seeing an **HTTP/2 request** but an **HTTP/1.1 response** from CloudFront is almost certainly due to the communication between CloudFront and your **Origin server**.

The most critical distinction to understand is the difference between the **Viewer Protocol** (Client to CloudFront) and the **Origin Protocol** (CloudFront to Origin).

---

## 🔁 The Protocol Split

CloudFront works as a **Reverse Proxy** and CDN, which means it manages two separate connections for every request:

1.  **Viewer-to-CloudFront (The Front End):**
    * This is the connection between your **Chrome browser** (the viewer) and the **CloudFront edge location**.
    * Since your browser requested **HTTP/2** and CloudFront is configured for it, this leg of the connection is successful: **HTTP/2**.
    * The Chrome Network Log shows the request version is **HTTP/2**.

2.  **CloudFront-to-Origin (The Back End):**
    * This is the connection from the CloudFront edge location to your actual content source (the Origin, e.g., an EC2 server, Application Load Balancer, or custom web server).
    * **The Problem:** CloudFront **currently uses HTTP/1.1** to communicate with **Custom Origins** (any origin that isn't an S3 bucket or a media origin).
    * CloudFront downgrades the request to HTTP/1.1 before sending it to your origin.
    * The origin server processes the request as HTTP/1.1 and sends an **HTTP/1.1 response** back to CloudFront.



### 💡 Why the Response Header is HTTP/1.1

When CloudFront receives the HTTP/1.1 response from your Origin, it **passes the response headers largely unchanged** back to the client. The `HTTP/1.1` version you see in the Chrome Network Log is a header from the **origin's response**, not an indication of the protocol used over the final link (CloudFront to Chrome).

Since the original request was over HTTP/2, the **payload transfer** still benefits from HTTP/2 features like multiplexing and header compression on the final leg back to the browser, even though the header says `HTTP/1.1`.

---

## ✅ Solution/Verification

You don't need to change anything if your goal is to utilize HTTP/2 performance between the client and CloudFront, as that is working correctly.

However, if you want the response version to reflect a different protocol or confirm the behavior:

* **Check the Origin Type:** If your origin is a **Custom Origin** (like your own web server), the HTTP/1.1 downgrade is expected and normal CloudFront behavior.
* **Check the `x-amz-cf-id` Header:** The presence of this header confirms the request went through CloudFront.
* **Origin Protocol Policy:** If you check your CloudFront Distribution's **Origin settings**, the **Origin Protocol Policy** will typically show you can choose between "HTTP Only," "HTTPS Only," or "Match Viewer," but the underlying version used between CloudFront and a Custom Origin remains **HTTP/1.1** for the time being (unless using a newer AWS service that explicitly supports HTTP/2/3 Origin connections).