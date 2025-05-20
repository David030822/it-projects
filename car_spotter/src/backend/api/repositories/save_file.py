import os
from uuid import uuid4
from fastapi import UploadFile
from typing import Optional

def save_file(file: Optional[UploadFile], folder: str = "uploads/profile_images") -> Optional[str]:
    if file:
        if not file.filename:
            raise ValueError("The uploaded file has no filename.")
        
        if not file.content_type.startswith("image/"):
            raise ValueError("Only image files are allowed.")
        
        if not os.path.exists(folder):
            os.makedirs(folder)
        
        file_extension = file.filename.split('.')[-1]
        file_name = f"{uuid4()}.{file_extension}"
        file_path = os.path.join(folder, file_name)
        
        with open(file_path, "wb") as f:
            f.write(file.file.read())
        
        return file_path
    
    return None

