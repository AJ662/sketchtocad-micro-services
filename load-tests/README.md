# SketchToCAD Load Testing (Extensive)

This directory contains performance tests for the SketchToCAD microservices system using [Locust](https://locust.io/).

## Full User Journey Simulation

Unlike a simple endpoint test, this script simulates a complete user session using `SequentialTaskSet`:

1.  **`upload_image`**: POSTs `test_image.jpg` to the API Gateway.
2.  **`wait_for_enhancement_selection`**: Polls the status until the image is processed and ready for color selection.
3.  **`submit_enhancement`**: POSTs a color enhancement preference.
4.  **`wait_for_clustering`**: Polls until the system is ready for user-defined clustering.
5.  **`submit_clustering`**: POSTs a mock clustering selection.
6.  **`wait_for_completion`**: Polls until the final DXF file is generated.
7.  **`download_dxf`**: Downloads the resulting CAD file and verifies its content.

## Prerequisites

- Python 3.10+
- `pip install -r requirements.txt`

## Running the Test

```bash
locust -f locustfile.py
```

1. Open `http://localhost:8089`.
2. Enter the number of users and spawn rate.
3. Observe how the system handles the cascading load across the Gateway, Orchestrator, Image Processing, Clustering, and DXF Export services.
