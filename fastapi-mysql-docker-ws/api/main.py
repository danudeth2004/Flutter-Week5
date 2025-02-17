# main.py
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from product import get_all_products, get_product_by_id, create_product, update_product, delete_product
from product.models import ProductModel
from typing import List

app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Hello CPSU!"}

# GET all products
@app.get("/products", response_model=List[ProductModel])
async def read_products():
    try:
        products = get_all_products()
        return products
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# GET product by ID
@app.get("/products/{product_id}", response_model=ProductModel)
async def read_product(product_id: int):
    try:
        product = get_product_by_id(product_id)
        return product
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

# POST create a new product
@app.post("/products", response_model=ProductModel, status_code=status.HTTP_201_CREATED)
async def create_new_product(product: ProductModel):
    try:
        product_id = create_product(product)
        return {**product.dict(), "id": product_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# PUT update a product by ID
@app.put("/products/{product_id}", response_model=ProductModel)
async def update_existing_product(product_id: int, product: ProductModel):
    try:
        update_product(product_id, product)
        return {**product.dict(), "id": product_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# DELETE a product by ID
@app.delete("/products/{product_id}")
async def delete_existing_product(product_id: int):
    try:
        delete_product(product_id)
        return {"message": "Product deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
