import requests
import re
from google.colab import files

# Function to perform OCR using OCRSpace API
def extract_text_from_image(image_path):
    url = "https://api.ocr.space/parse/image"
    ocrspace_api_key = "K83317313588957"  # Replace with your OCRSpace API key

    with open(image_path, 'rb') as file:
        response = requests.post(url,
                                 files={"file": file},
                                 data={
                                     "apikey": ocrspace_api_key,
                                     "language": "eng",
                                     "isOverlayRequired": "false",
                                     "isTable": "true",
                                     "detectOrientation": "true",
                                     "OCREngine": "2",
                                 })

    ocr_result = response.json()

    if ocr_result["OCRExitCode"] == 1:
        return ocr_result["ParsedResults"][0]["ParsedText"]
    else:
        return "Error: " + ocr_result.get("ErrorMessage", "Unknown error")

# Function to extract invoice data from text using regex
def extract_invoice_data(text):
    data = {}
    
    # Patterns to match each required field
    patterns = {
        "ICE": r"ICE\s*[:]*\s*(\d+)",
        "IF": r"IF\s*[:]*\s*(\d+)",
        "Destinataire": r"Destinataire\s*[:]*\s*([^\n]+)",
        "Total": r"Total à régler.*?:\s*([\d,]+)",
        "Date d'échéance": r"Date d['’]écheance.*?(\d{2}\.\d{2}\.\d{4})",
        "TVA": r"Total taxes.*?:\s*([\d,]+)",
        "N° de facture": r"N° Facture\s*[:]*\s*(\d+)",
        "Date de facturation": r"Date\s*(\d{2}\.\d{2}\.\d{4})",
    }
    
    for key, pattern in patterns.items():
        match = re.search(pattern, text)
        if match:
            data[key] = match.group(1)
        else:
            data[key] = None  # If no match is found, set as None
    
    return data

# Upload the image
uploaded = files.upload()

# Get the uploaded file name
file_name = next(iter(uploaded))

# Extract text from the uploaded image
ocr_text = extract_text_from_image(file_name)
print("Extracted Text: ", ocr_text)

# Extract invoice data from the OCR text
invoice_data = extract_invoice_data(ocr_text)
print("\nExtracted Invoice Data:")
for key, value in invoice_data.items():
    print(f"{key}: {value}")
