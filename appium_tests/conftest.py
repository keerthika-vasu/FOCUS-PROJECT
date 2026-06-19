import os
import pytest
import logging
from appium import webdriver
from appium.options.android import UiAutomator2Options

# Configure logging
LOG_DIR = os.path.join(os.path.dirname(__file__), "reports")
os.makedirs(LOG_DIR, exist_ok=True)
os.makedirs(os.path.join(LOG_DIR, "screenshots"), exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(LOG_DIR, "appium.log"), mode="w", encoding="utf-8"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("AppiumTest")

@pytest.fixture(scope="function")
def driver(request):
    logger.info("Initializing Appium driver...")
    
    # Read capability overrides from environment or use defaults
    app_path = os.environ.get("APP_PATH", "build/app/outputs/flutter-apk/app-debug.apk")
    device_name = os.environ.get("DEVICE_NAME", "Android Emulator")
    platform_version = os.environ.get("PLATFORM_VERSION", "11.0")
    appium_server = os.environ.get("APPIUM_SERVER", "http://localhost:4723")
    
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.device_name = device_name
    options.platform_version = platform_version
    options.automation_name = "UiAutomator2"
    
    # If the app exists, set it. Otherwise, assume it might already be installed or we use package/activity names.
    if os.path.exists(app_path):
        options.app = os.path.abspath(app_path)
        logger.info(f"Using application path: {options.app}")
    else:
        # Default fallback package/activity for Focus Shield App (Flutter standard)
        options.app_package = os.environ.get("APP_PACKAGE", "com.example.focus_shield_app")
        options.app_activity = os.environ.get("APP_ACTIVITY", "com.example.focus_shield_app.MainActivity")
        logger.warning(f"APK not found at {app_path}. Attempting to launch by package/activity: {options.app_package}")
        
    options.no_reset = False
    options.auto_grant_permissions = True
    
    try:
        driver = webdriver.Remote(appium_server, options=options)
        logger.info("Appium driver session created successfully.")
    except Exception as e:
        logger.error(f"Failed to start Appium session: {e}")
        raise e
        
    yield driver
    
    # Take screenshot if test failed
    if hasattr(request.node, "rep_call") and request.node.rep_call.failed:
        test_name = request.node.name
        screenshot_name = f"{test_name}_failed.png"
        screenshot_path = os.path.join(LOG_DIR, "screenshots", screenshot_name)
        try:
            driver.save_screenshot(screenshot_path)
            logger.error(f"Test failed! Screenshot saved to {screenshot_path}")
            # Save the screenshot path to the node so the runner can collect it
            request.node.screenshot_path = screenshot_path
        except Exception as screenshot_err:
            logger.error(f"Failed to take screenshot: {screenshot_err}")
            
    logger.info("Tearing down Appium driver session...")
    try:
        driver.quit()
    except Exception as quit_err:
        logger.error(f"Error during quit: {quit_err}")

# Hook to fetch test results for screenshots on failure
@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)
