#!/usr/bin/env python3
"""
Convert Markdown to PDF using weasyprint and markdown
"""

import markdown
from weasyprint import HTML, CSS
import os

def markdown_to_pdf(md_file, pdf_file):
    """Convert markdown file to PDF"""
    
    # Read markdown file
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['tables', 'fenced_code', 'codehilite'])
    
    # Add HTML structure and CSS styling
    html_template = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                line-height: 1.6;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                color: #333;
            }}
            h1 {{
                color: #2c3e50;
                border-bottom: 2px solid #3498db;
                padding-bottom: 10px;
            }}
            h2 {{
                color: #34495e;
                border-bottom: 1px solid #bdc3c7;
                padding-bottom: 5px;
                margin-top: 30px;
            }}
            h3 {{
                color: #7f8c8d;
                margin-top: 20px;
            }}
            code {{
                background-color: #f8f9fa;
                padding: 2px 6px;
                border-radius: 3px;
                font-family: 'Courier New', monospace;
                font-size: 0.9em;
            }}
            pre {{
                background-color: #2c3e50;
                color: #ecf0f1;
                padding: 15px;
                border-radius: 5px;
                overflow-x: auto;
            }}
            pre code {{
                background-color: transparent;
                padding: 0;
                color: #ecf0f1;
            }}
            table {{
                border-collapse: collapse;
                width: 100%;
                margin: 20px 0;
            }}
            th, td {{
                border: 1px solid #ddd;
                padding: 8px;
                text-align: left;
            }}
            th {{
                background-color: #3498db;
                color: white;
            }}
            blockquote {{
                border-left: 4px solid #3498db;
                padding-left: 15px;
                margin-left: 0;
                color: #7f8c8d;
            }}
            ul, ol {{
                margin: 10px 0;
                padding-left: 20px;
            }}
            li {{
                margin: 5px 0;
            }}
            a {{
                color: #3498db;
                text-decoration: none;
            }}
            a:hover {{
                text-decoration: underline;
            }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """

    # Convert HTML to PDF
    HTML(string=html_template).write_pdf(pdf_file)
    print(f"PDF created successfully: {pdf_file}")

if __name__ == "__main__":
    md_file = "/Users/b/data/projects/althea-sales-ops-cpg/01_ops_command_center/docs/PROJECT_1_SETUP_GUIDE.md"
    pdf_file = "/Users/b/data/projects/althea-sales-ops-cpg/01_ops_command_center/docs/PROJECT_1_SETUP_GUIDE.pdf"

    markdown_to_pdf(md_file, pdf_file)
