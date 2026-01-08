from locust import HttpUser, task, between, SequentialTaskSet
import os
import random
import time


class UserJourney(SequentialTaskSet):
    """
    Simulates a complete user journey:
    1. Upload image
    2. Wait for processing & automated enhancement generation
    3. Choose enhancement
    4. Wait for clustering readiness
    5. Submit clustering
    6. Wait for completion
    7. Download DXF
    """

    def on_start(self):
        self.test_image_path = os.path.join(
            os.path.dirname(__file__), "images", "test_image.jpg"
        )
        self.saga_id = None
        self.session_id = None

    @task
    def upload_image(self):
        if not os.path.exists(self.test_image_path):
            self.interrupt()
            return

        with open(self.test_image_path, "rb") as image_file:
            files = {"file": ("test_image.jpg", image_file, "image/jpeg")}
            with self.client.post(
                "/api/v1/workflow/start", files=files, catch_response=True
            ) as response:
                if response.status_code == 200:
                    data = response.json()
                    self.saga_id = data.get("saga_id")
                    self.session_id = data.get("session_id")
                    response.success()
                else:
                    response.failure(f"Upload failed: {response.status_code}")
                    self.interrupt()

    @task
    def wait_for_enhancement_selection(self):
        """Poll until status is AWAITING_ENHANCEMENT_SELECTION"""
        attempts = 0
        while attempts < 20:
            with self.client.get(
                f"/api/v1/workflow/{self.saga_id}", catch_response=True
            ) as response:
                if response.status_code == 200:
                    status = response.json().get("status")
                    if status == "AWAITING_ENHANCEMENT_SELECTION":
                        response.success()
                        return
                    elif status == "FAILED":
                        response.failure("Workflow failed during image processing")
                        self.interrupt()
                        return
                else:
                    response.failure(f"Status check failed: {response.status_code}")

            attempts += 1
            time.sleep(2)

        self.interrupt()

    @task
    def submit_enhancement(self):
        payload = {"enhancement_method": "color_ratios"}  # Default test method
        with self.client.post(
            f"/api/v1/workflow/{self.saga_id}/enhancement",
            json=payload,
            catch_response=True,
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(
                    f"Enhancement submission failed: {response.status_code}"
                )
                self.interrupt()

    @task
    def wait_for_clustering(self):
        """Poll until status is AWAITING_CLUSTERING"""
        attempts = 0
        while attempts < 20:
            with self.client.get(
                f"/api/v1/workflow/{self.saga_id}", catch_response=True
            ) as response:
                if response.status_code == 200:
                    status = response.json().get("status")
                    if status == "AWAITING_CLUSTERING":
                        response.success()
                        return
                else:
                    response.failure(f"Status check failed: {response.status_code}")

            attempts += 1
            time.sleep(2)

        self.interrupt()

    @task
    def submit_clustering(self):
        # Mock clustering data (usually selected by user in UI)
        payload = {"clusters_data": {"0": [0, 1, 2], "1": [3, 4, 5]}}
        with self.client.post(
            f"/api/v1/workflow/{self.saga_id}/clustering",
            json=payload,
            catch_response=True,
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(
                    f"Clustering submission failed: {response.status_code}"
                )
                self.interrupt()

    @task
    def wait_for_completion(self):
        """Poll until status is COMPLETED"""
        attempts = 0
        while attempts < 30:
            with self.client.get(
                f"/api/v1/workflow/{self.saga_id}", catch_response=True
            ) as response:
                if response.status_code == 200:
                    status = response.json().get("status")
                    if status == "COMPLETED":
                        response.success()
                        return
                    elif status == "FAILED":
                        response.failure("Workflow failed during export")
                        self.interrupt()
                        return
                else:
                    response.failure(f"Status check failed: {response.status_code}")

            attempts += 1
            time.sleep(2)

        self.interrupt()

    @task
    def download_dxf(self):
        with self.client.get(
            f"/api/v1/workflow/{self.saga_id}/download", catch_response=True
        ) as response:
            if response.status_code == 200:
                if len(response.content) > 0:
                    response.success()
                else:
                    response.failure("Downloaded DXF is empty")
            else:
                response.failure(f"DXF download failed: {response.status_code}")

        # Journey complete
        self.interrupt()


class SketchToCadUser(HttpUser):
    tasks = [UserJourney]
    wait_time = between(2, 10)
    host = (
        "http://k8s-default-sketchto-fa45f41f7a-1406979019.eu-west-1.elb.amazonaws.com"
    )
