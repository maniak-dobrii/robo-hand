#  robo-hand API Description

I try to keep everything here as simple as possible while not crutching everything too much. I don't have much time and motivation to
keep everything here production quality.

**All requests are HTTP GET**'s because I don't want to introduce superfluous complexity where I can not. Space on device is really limited,
adopting semantically correct HTTP methods will cause me, for example, to send parameters in body for POST requests, that means I
have to parse it on the device. That's additional redundant complexity in code, wasting precious space for some JSON parsing
implementation while getting not much good back. So I made the best pet-project decision ever - no caching + all HTTP GETs.

**API returns response body as JSON or JSON fragment**, where JSON fragment is any valid JSON element. **Empty response body is
allowed.** In real world API I would stand on fixed response format, where any valid (successfull or failed) responce is a JSON object,
but here it is just fine.


Response is considered succesfull if it has 200 HTTP status code and empty/valid JSON/valid JSON fragment body. Other requrements
may apply per request basis.

* in schemas indicates required field.


## GET /deviceInfo
Returns current device info including name and API version. Currently there's not much use of this but to detect if device is up and running.

**Request parameters:**
<none>

**Response schema:**
{
    "name": String*, // device name for debugging purposes
    "apiVersion": String*, // semver device version, future app versions might inspect it
}


## GET /setPosture
Asks device to flex fingers so that they form desired posture. Response contains

**Request parameters:**
thumb: Float - thumb extension rate, 0 - closed, 1 - fully extended
index: Float - thumb extension rate, 0 - closed, 1 - fully extended
middle:Float - thumb extension rate, 0 - closed, 1 - fully extended
ring: Float - thumb extension rate, 0 - closed, 1 - fully extended
pinky: Float - thumb extension rate, 0 - closed, 1 - fully extended

Every parameter is optional. If argument not supplied corresponding finger is not moved.

**Response schema:**
"OK"
