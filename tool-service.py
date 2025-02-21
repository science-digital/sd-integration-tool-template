import os
import sys
from time import sleep

this_dir = os.path.dirname(__file__)
src_dir = os.path.abspath(os.path.join(this_dir, "../../src"))
sys.path.append(src_dir)

from fastapi import Body, FastAPI
from signal import signal, SIGTERM

from ivcap_fastapi import getLogger, service_log_config, logging_init
from ivcap_ai_tool import create_tool_definition, start_server

from pydantic import BaseModel, Field

import math

logging_init()
logger = getLogger("app")

# shutdown pod cracefully
signal(SIGTERM, lambda _1, _2: sys.exit(0))

title="AI tool to check for prime numbers"
description = """
AI tool to help determining if a number is a prime number.
"""

app = FastAPI(
    title=title,
    description=description,
    version=os.environ.get("VERSION", "???"),
    contact={
        "name": "Max Ott",
        "email": "max.ott@data61.csiro.au",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
    docs_url="/api",
    root_path=os.environ.get("IVCAP_ROOT_PATH", "")
)

@app.post("/")
def is_prime(number: int = Body(..., embed=True)) -> bool:
    """
    Checks if a number is a prime number.

    Args:
        number: The number to check.

    Returns:
        True if the number is prime, False otherwise.
    """
    if number <= 1:
        return False
    if number <= 3:
        return True
    if number % 2 == 0 or number % 3 == 0:
        return False

    for i in range(5, int(math.sqrt(number)) + 1, 6):
        if number % i == 0 or number % (i + 2) == 0:
            return False

    return True


@app.get("/")
def get_tool_definition():
    return create_tool_definition(is_prime)

# Allows platform to check if everything is OK
@app.get("/_healtz")
def healtz():
    return {"version": os.environ.get("VERSION", "???")}

# Start server
start_server(app, title, is_prime, logger)
