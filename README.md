# PrintCSS.live Backend

This service provides an API to generate PDFs using various tools.

## Building the Docker Container

To build the Docker container for this service, follow these steps:

1. Clone this repository:
   ```
   git clone https://github.com/azettl/printcss-live-backend.git
   cd printcss-live-backend
   ```

2. Build the Docker image:
   ```
   docker build -t printcss-live-backend .
   ```

   With AH Formatter (needs to be an *.rpm.gz file):
   ```
   docker build --build-arg AH_FORMATTER_FILE=AHFormatter.rpm.gz -t printcss-live-backend .
   ```
    
   With BFO Publisher (needs to be the bfopublisher-bundle-*.jar file):
   ```
   docker build --build-arg BFO_PUBLISHER_FILE=bfopublisher-bundle-1.3.jar -t printcss-live-backend .
   ```

   With Typeset.sh (needs to be a *.phar file):
   ```
   docker build --build-arg TYPESETSH_FILE=typesetsh.phar -t printcss-live-backend .
   ```

   With all renderes:
   ```
   docker build --build-arg AH_FORMATTER_FILE=AHFormatter.rpm.gz --build-arg BFO_PUBLISHER_FILE=bfopublisher-bundle-1.3.jar --build-arg TYPESETSH_FILE=typesetsh.phar -t printcss-live-backend .
   ```

3. Create SSL Cert:

   ```
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/privkey.pem -out /etc/ssl/certs/fullchain.pem
   ```

4. Run the container:
   ```
   docker run -d -p 443:5000 --name printcss-live-backend-container -v /etc/ssl/certs/fullchain.pem:/opt/ssl/certs/fullchain.pem -v /etc/ssl/private/privkey.pem:/opt/ssl/private/privkey.pem printcss-live-backend
   ```

   CORS
   
   The default allowed origin is `http://localhost:*`, if you want to change it, pass the ALLOWED_ORIGIN parameter.
   ```
   docker run -d -p 5000:5000 -e ALLOWED_ORIGIN="http://yourhost:*" --name printcss-live-backend-container printcss-live-backend
   ```

## API Usage

### Endpoint
`/generate_pdf`

### Method
POST

### Parameters

- **tool** (string, required): The PDF generation tool to use. Options: pdfreactor, prince, vivliostyle, pagedjs, weasyprint, ahformatter, bfopublisher, typesetsh
- **input_file** (file, required): The input HTML file to convert to PDF

### Response

- Success: Returns the generated PDF file
- Error: Returns an error message with status code 400 or 500

### Example cURL command

```
curl -X POST -F 'tool=weasyprint' -F 'input_file=@/path/to/your/input.html' http://localhost:5000/generate_pdf --output output.pdf
```

### Endpoint
`/supported_tools`

### Method
GET

### Response

Returns a list of supported tools.

### Example cURL command

```
curl http://localhost:5000/supported_tools
```

## API Documentation

For detailed API documentation in JSON format, send a GET request to the `/generate_pdf` endpoint.

## Supported PDF Generation Tools

This service supports the following PDF generation tools:

|   | Name | Website | License |
|---|------|---------|---------|
| 💰 | PDFreactor | [https://www.pdfreactor.com/](https://www.pdfreactor.com/) | [License](https://www.pdfreactor.com/product/license/PDFreactor%20Software%20License%20Agreement.pdf) |
| 💰 | Prince | [https://www.princexml.com/](https://www.princexml.com/) | [License](https://www.princexml.com/license/) |
| 🆓 | Vivliostyle | [https://vivliostyle.org/](https://vivliostyle.org/) | [License](https://github.com/vivliostyle/vivliostyle-cli?tab=AGPL-3.0-1-ov-file#readme) |
| 🆓 | PagedJS | [https://pagedjs.org/](https://pagedjs.org/) | [License](https://gitlab.coko.foundation/pagedjs/pagedjs-cli/-/blob/main/LICENSE) |
| 🆓 | WeasyPrint | [https://weasyprint.org/](https://weasyprint.org/) | [License](https://doc.courtbouillon.org/weasyprint/stable/) |
| 💰 | AH Formatter | [https://www.antennahouse.com/](https://www.antennahouse.com/) | [License](https://www.antennahouse.com/licensing) |
| 💰 | BFO Publisher | [https://publisher.bfo.com/](https://publisher.bfo.com/) | [License](https://publisher.bfo.com/live/help/license.html) |
| 💰 | Typeset.sh | [https://typeset.sh/](https://typeset.sh/) | [License](https://typeset.sh/en/licence) |

Each tool has its own strengths and may produce slightly different results. This docker container will help you to choose the tool that best fits your specific requirements.

There is no possibility to add the license keys for PDFreactor, AH Formatter and Prince yet.

## Notes
- The service runs on port 5000 inside the container, which is mapped to port 443 on your host machine in the example run command above.

For any issues or feature requests, please open an issue on this GitHub repository.
