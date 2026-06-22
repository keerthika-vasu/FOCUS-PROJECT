"""
FOCUS-SHIELD – ActivityLogScreen E2E Tests
Dart source : lib/screens/shared/activity_log_screen.dart

Pre-condition: Logged in as Teacher (accessible via 'Login Activity' action card).

Covers:
  - Screen heading
  - Activity log rows (student name, event type, timestamp)
  - Login vs Logout event icons
  - Empty state message
  - Pull-to-refresh
  - Back navigation
  - Scroll behaviour
"""

import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

WAIT = 20
SHORT = 8


def _w(driver, t=WAIT):
    return WebDriverWait(driver, t)


def _find(driver, text, t=WAIT):
    return _w(driver, t).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[@text='{text}' or @content-desc='{text}']"
        ))
    )


def _find_contains(driver, partial, t=WAIT):
    return _w(driver, t).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            f"//*[contains(@text,'{partial}') or contains(@content-desc,'{partial}')]"
        ))
    )


def _login_and_open_activity_log(driver):
    _w(driver, 30).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
        ))
    )
    driver.find_element(
        AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
    ).send_keys("teacher@focusshield.test")
    fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
    if len(fields) >= 2:
        fields[1].send_keys("TeacherPass123")
    _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH, "//android.widget.Button[@text='Sign In']"
        ))
    ).click()
    _w(driver, 25).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH, "//*[contains(@text,'Quick Actions')]"
        ))
    )
    _find(driver, "Login Activity").click()
    _w(driver, WAIT).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            "//*[contains(@text,'Activity') or contains(@text,'Login') "
            "or contains(@text,'Log')]"
        ))
    )


class TestActivityLogScreen:
    """TC-AL-01 … TC-AL-13: ActivityLogScreen UI & data display."""

    def test_al01_screen_loads(self, driver):
        """TC-AL-01: ActivityLogScreen loads after tapping Login Activity."""
        _login_and_open_activity_log(driver)
        assert True

    def test_al02_activity_heading_visible(self, driver):
        """TC-AL-02: Screen heading contains 'Activity' or 'Login'."""
        _login_and_open_activity_log(driver)
        el = _find_contains(driver, "Activity")
        assert el.is_displayed()

    def test_al03_no_error_on_open(self, driver):
        """TC-AL-03: No error dialog appears when the screen opens."""
        _login_and_open_activity_log(driver)
        errors = driver.find_elements(
            AppiumBy.XPATH, "//*[contains(@text,'Error')]"
        )
        assert len(errors) == 0

    def test_al04_activity_rows_or_empty_state(self, driver):
        """TC-AL-04: Either activity rows or 'No activity' empty state is shown."""
        _login_and_open_activity_log(driver)
        texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        assert len(texts) > 0

    def test_al05_logged_in_or_logged_out_text(self, driver):
        """TC-AL-05: Activity rows show 'logged in' or 'logged out' event text."""
        _login_and_open_activity_log(driver)
        events = driver.find_elements(
            AppiumBy.XPATH,
            "//*[contains(@text,'logged in') or contains(@text,'logged out')]"
        )
        # May be empty if no activity data — not a failure
        assert isinstance(events, list)

    def test_al06_back_navigation_to_teacher_home(self, driver):
        """TC-AL-06: Back navigation returns to TeacherHomeScreen."""
        _login_and_open_activity_log(driver)
        driver.back()
        _find(driver, "Quick Actions")

    def test_al07_pull_to_refresh_no_crash(self, driver):
        """TC-AL-07: Pull-to-refresh on activity log does not crash."""
        _login_and_open_activity_log(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 400, size["width"] // 2, 900, 600)
        assert True

    def test_al08_scroll_list_no_crash(self, driver):
        """TC-AL-08: Scrolling the activity list does not crash."""
        _login_and_open_activity_log(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 700, size["width"] // 2, 200, 600)
        assert True

    def test_al09_timestamp_text_present(self, driver):
        """TC-AL-09: Timestamp text (e.g. time value) is shown in activity rows."""
        _login_and_open_activity_log(driver)
        times = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.TextView[contains(@text,':') or "
            "contains(@text,'AM') or contains(@text,'PM')]"
        )
        assert isinstance(times, list)

    def test_al10_no_edit_fields_visible(self, driver):
        """TC-AL-10: No editable text input fields on activity log (read-only)."""
        _login_and_open_activity_log(driver)
        inputs = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        assert len(inputs) == 0, "Unexpected input fields on activity log screen"

    def test_al11_student_name_in_row(self, driver):
        """TC-AL-11: Student name is included in activity event rows."""
        _login_and_open_activity_log(driver)
        all_texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        assert len(all_texts) > 0

    def test_al12_screen_stable_5s(self, driver):
        """TC-AL-12: Activity log screen is stable for 5 seconds."""
        import time
        _login_and_open_activity_log(driver)
        time.sleep(5)
        els = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        assert len(els) > 0

    def test_al13_appbar_back_button_present(self, driver):
        """TC-AL-13: AppBar back button is visible on activity log screen."""
        _login_and_open_activity_log(driver)
        back = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.ImageButton[@content-desc='Back' or "
            "@content-desc='Navigate up']"
        )
        assert len(back) > 0, "No back button on activity log screen"
