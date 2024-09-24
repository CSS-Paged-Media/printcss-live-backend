from flask import Flask, request, send_file, jsonify, render_template_string
import subprocess
import os
import requests
import pwd
import grp

app = Flask(__name__)

# HTML template for the root endpoint
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF Generation Service</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; max-width: 800px; margin: 0 auto; }
        h1 { color: #333; }
        h2 { color: #666; }
        code { background-color: #f4f4f4; padding: 2px 5px; border-radius: 3px; }
        pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>PDF Generation Service</h1>
    <p>This service provides an API to generate PDFs using various tools.</p>
    
    <h2>API Usage</h2>
    <p>Endpoint: <code>/generate_pdf</code></p>
    <p>Method: POST</p>
    
    <h3>Parameters:</h3>
    <ul>
        <li><strong>tool</strong> (string, required): The PDF generation tool to use. Options: pdfreactor, prince, vivliostyle, weasyprint</li>
        <li><strong>input_file</strong> (file, required): The input HTML file to convert to PDF</li>
    </ul>
    
    <h3>Response:</h3>
    <ul>
        <li>Success: Returns the generated PDF file</li>
        <li>Error: Returns an error message with status code 400 or 500</li>
    </ul>
    
    <h3>Example cURL command:</h3>
    <pre><code>curl -X POST -F 'tool=weasyprint' -F 'input_file=@/path/to/your/input.html' http://localhost:5000/generate_pdf --output output.pdf</code></pre>
    
    <h2>API Documentation</h2>
    <p>For detailed API documentation in JSON format, send a GET request to the <code>/generate_pdf</code> endpoint.</p>
</body>
</html>
"""

def run_command(command):
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        return None, result.stdout  # No error, return stdout
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr}", None

@app.route('/generate_pdf', methods=['POST'])
def generate_pdf():
    try:
        tool = request.form['tool']
        input_file = request.files['input_file']
        
        # Save the input file
        input_path = os.path.join('/data', input_file.filename)
        input_file.save(input_path)
        
        # Generate a unique output filename
        output_filename = f"output_{tool}_{os.path.splitext(input_file.filename)[0]}.pdf"
        output_path = os.path.join('/data', output_filename)
        
        # Run the appropriate tool
        if tool == 'pdfreactor':
            error, output = run_command(['java', '-jar', '/opt/PDFreactor/lib/pdfreactor.jar', '-i', input_path, '-o', output_path])
        elif tool == 'prince':
            error, output = run_command(['prince', input_path, '-o', output_path])
        elif tool == 'vivliostyle':
            error, output = run_command(['vivliostyle', 'build', input_path, '-o', output_path])
        elif tool == 'weasyprint':
            error, output = run_command(['weasyprint', input_path, output_path])
        else:
            app.logger.error(f"Unsupported tool: {tool}")
            return "Unsupported tool", 400
        
        if error or (output and "error" in output.lower()):
            app.logger.error(f"Error during PDF generation with {tool}: {error or output}")
            return error or output, 500
        
        # Check if the output file was created
        if not os.path.exists(output_path):
            error_msg = f"Error: {tool} did not generate a PDF file"
            app.logger.error(error_msg)
            return error_msg, 500
        
        # Send the generated PDF
        return send_file(output_path, as_attachment=True)
    except Exception as e:
        app.logger.error(f"Unexpected error in generate_pdf: {str(e)}")
        return "An unexpected error occurred", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)