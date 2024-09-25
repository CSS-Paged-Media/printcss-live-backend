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

   Or with AH Formatter (needs to be an *.rpm.gz file):
   ```
   docker build --build-arg AH_FORMATTER_FILE=AHFormatter.rpm.gz -t printcss-live-backend .
   ```

3. Run the container:
   ```
   docker run -d -p 5000:5000 --name printcss-live-backend-container printcss-live-backend
   ```

## API Usage

### Endpoint
`/generate_pdf`

### Method
POST

### Parameters

- **tool** (string, required): The PDF generation tool to use. Options: pdfreactor, prince, vivliostyle, weasyprint, ahformatter
- **input_file** (file, required): The input HTML file to convert to PDF

### Response

- Success: Returns the generated PDF file
- Error: Returns an error message with status code 400 or 500

### Example cURL command

```
curl -X POST -F 'tool=weasyprint' -F 'input_file=@/path/to/your/input.html' http://localhost:5000/generate_pdf --output output.pdf
```

## API Documentation

For detailed API documentation in JSON format, send a GET request to the `/generate_pdf` endpoint.

## Supported PDF Generation Tools

This service supports the following PDF generation tools:

1. PDFreactor ([License](https://www.pdfreactor.com/product/license/PDFreactor%20Software%20License%20Agreement.pdf))
2. Prince ([License](https://www.princexml.com/license/))
3. Vivliostyle ([License](https://github.com/vivliostyle/vivliostyle-cli?tab=AGPL-3.0-1-ov-file#readme))
4. WeasyPrint ([License](https://doc.courtbouillon.org/weasyprint/stable/))
5. AH Formatter ([License](https://www.antennahouse.com/licensing))

Each tool has its own strengths and may produce slightly different results. This docker container will help you to choose the tool that best fits your specific requirements.

There is no possibility to add the license keys for PDFreactor, AH Formatter and Prince yet.

## Notes
- The service runs on port 5000 inside the container, which is mapped to port 5000 on your host machine in the example run command above.

For any issues or feature requests, please open an issue on this GitHub repository.
