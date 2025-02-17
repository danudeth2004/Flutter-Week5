from pathlib import Path
import os
import pymysql.cursors
from pymysql import converters
from fastapi import HTTPException, status

converions = converters.conversions
converions[pymysql.FIELD_TYPE.BIT] = lambda x: False if x == b'\x00' else True

def init_connection():
    connection = pymysql.connect(host=os.getenv("DATABASE_HOST"),
                                 port=3306,
                                 user=os.environ.get("DATABASE_USERNAME"),
                                 password=os.environ.get("DATABASE_PASSWORD"),
                                 database=os.environ.get("DATABASE"),
                                 cursorclass=pymysql.cursors.DictCursor,
                                 conv=converions)
    return connection

        
def query_get(sql, param):
    try:
        connection = init_connection()
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(sql, param)
                return cursor.fetchall()
    except Exception as e:
        raise HTTPException(
             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database error: " + str(e),
        )

def query_create(sql, param):
    connection = init_connection()
    try:
        connection = init_connection()
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(sql, param)
                connection.commit()
                return cursor.lastrowid
    except Exception as e:
        raise HTTPException(
             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database error: " + str(e),
        )
        
def query_update(sql, param):
    connection = init_connection()
    try:
        connection = init_connection()
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(sql, param)
                connection.commit()
                return True
    except Exception as e:
        raise HTTPException(
             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database error: " + str(e),
        )