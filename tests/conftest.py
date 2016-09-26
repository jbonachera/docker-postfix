import pytest
import testinfra

# Use testinfra to get a handy function to run commands locally
check_output = testinfra.get_backend(
    "local://"
).get_module("Command").check_output


@pytest.fixture
def TestinfraBackend(request):
    # Override the TestinfraBackend fixture,
    # all testinfra fixtures (i.e. modules) depend on it.

    docker_id = check_output(
        "docker run -d %s && sleep 5", request.param)

    def teardown():
        check_output("docker rm -f %s", docker_id)

    # Destroy the container at the end of the fixture life
    request.addfinalizer(teardown)

    # Return a dynamic created backend
    return testinfra.get_backend("docker://" + docker_id)
def pytest_generate_tests(metafunc):
    if "TestinfraBackend" in metafunc.fixturenames:

        # Lookup "docker_images" marker
        marker = getattr(metafunc.function, "docker_images", None)
        if marker is not None:
            images = marker.args
        else:
            # Default image
            images = ["jbonachera/postfix:latest"]

        # If the test has a destructive marker, we scope TestinfraBackend
        # at function level (i.e. executing for each test). If not we scope
        # at session level (i.e. all tests will share the same container)
        if getattr(metafunc.function, "destructive", None) is not None:
            scope = "function"
        else:
            scope = "session"

        metafunc.parametrize(
            "TestinfraBackend", images, indirect=True, scope=scope)

