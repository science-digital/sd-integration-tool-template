import math
from pydantic import BaseModel, Field
from pydantic import BaseModel, ConfigDict

from ivcap_service import getLogger, Service, JobContext
from ivcap_ai_tool import start_tool_server, ToolOptions, ivcap_ai_tool, logging_init

logging_init()
logger = getLogger("app")


# Service details.
service = Service(
    name="A tool to check whether a number is prime",
    contact={
        "name": "Your Name",
        "email": "your.name@data61.csiro.au",
    },
    license={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
)

# Specify input value(s).
class Request(BaseModel):
    # A unique schema identifier for this data format.
    jschema: str = Field("urn:sd:schema.is-prime.request.1", alias="$schema")
    # An example input value.
    number: int = Field(description="The number to check as prime.")

    # An example showing how to supply the input data.
    model_config = ConfigDict(json_schema_extra={
        "example": {
            "$schema": "urn:sd:schema.is-prime.request.1",
            "number": 997
        }
    })

# Specify result value(s).
class Result(BaseModel):
    # A unique schema identifier for this data format.
    jschema: str = Field("urn:sd:schema.is-prime.1", alias="$schema")
    # Two example result values.
    number: int = Field(description="The number that was checked as prime.")
    is_prime: bool = Field(description="true if number is prime, false otherwise.")

    # An example showing what the result will look like.
    model_config = ConfigDict(json_schema_extra={
        "example": {
            "$schema": "urn:sd:schema.is-prime.1",
            "number": 997,
            "is_prime": True
        }
    })

# API Functionality.
@ivcap_ai_tool("/", opts=ToolOptions(tags=["Prime Checker"]))
def is_prime(req: Request, jobCtxt: JobContext) -> Result:
    """
    Checks if a number is prime.
    """
    number = req.number
    jobCtxt.report.step_started("main", f"Checking '{number}'")
    is_prime = True
    if number <= 1:
        is_prime = False
    elif number <= 3:
        is_prime = True
    elif number % 2 == 0 or number % 3 == 0:
        is_prime = False
    else:
        for i in range(5, int(math.sqrt(number)) + 1, 6):
            if number % i == 0 or number % (i + 2) == 0:
                is_prime = False
                break

    jobCtxt.report.step_finished("main", f"Is '{number}' a prime? {is_prime}")
    return Result(number=number, is_prime=is_prime)


if __name__ == "__main__":
    start_tool_server(service)
