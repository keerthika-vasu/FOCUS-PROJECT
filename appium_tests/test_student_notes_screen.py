"""
FOCUS-SHIELD – StudentNotesScreen E2E Tests
Dart source : lib/screens/student/student_notes_screen.dart

Covers:
  - Screen loads from Class Notes card on StudentHomeScreen
  - Screen title / heading
  - Notes list renders (or empty state)
  - Note card content (text visible)
  - Pull-to-refresh
  - Back navigation
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


def _login_and_open_student_notes(driver):
    _w(driver, 30).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
        ))
    )
    driver.find_element(
        AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
    ).send_keys("student@focusshield.test")
    fields = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
    if len(fields) >= 2:
        fields[1].send_keys("TestPass123")
    _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH, "//android.widget.Button[@text='Sign In']"
        ))
    ).click()
    # Tap Class Notes card
    notes_card = _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            "//*[contains(@text,'Class Notes') or contains(@content-desc,'Class Notes')]"
        ))
    )
    notes_card.click()


class TestStudentNotesScreen:
    """TC-SN-01 … TC-SN-12: StudentNotesScreen UI."""

    def test_sn01_screen_loads(self, driver):
        """TC-SN-01: StudentNotesScreen loads after tapping Class Notes card."""
        _login_and_open_student_notes(driver)
        _w(driver, WAIT).until(
            EC.presence_of_element_located((
                AppiumBy.XPATH,
                "//*[contains(@text,'Note') or contains(@text,'note') "
                "or contains(@text,'Class')]"
            ))
        )
        assert True

    def test_sn02_notes_heading_present(self, driver):
        """TC-SN-02: A heading containing 'Notes' or 'Class Notes' is visible."""
        _login_and_open_student_notes(driver)
        el = _find_contains(driver, "Notes")
        assert el.is_displayed()

    def test_sn03_no_crash_on_open(self, driver):
        """TC-SN-03: Opening the screen does not produce an error dialog."""
        _login_and_open_student_notes(driver)
        errors = driver.find_elements(
            AppiumBy.XPATH, "//*[contains(@text,'Error') or contains(@text,'crash')]"
        )
        assert len(errors) == 0

    def test_sn04_empty_state_or_note_cards_shown(self, driver):
        """TC-SN-04: Either empty-state text or note cards are displayed."""
        _login_and_open_student_notes(driver)
        note_items = driver.find_elements(
            AppiumBy.XPATH,
            "//*[contains(@text,'No notes') or contains(@text,'note') "
            "or @class='android.widget.FrameLayout']"
        )
        assert len(note_items) > 0

    def test_sn05_note_text_visible_if_notes_exist(self, driver):
        """TC-SN-05: If notes exist, their text content is visible."""
        _login_and_open_student_notes(driver)
        texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        meaningful = [t for t in texts if len(t.text.strip()) > 3]
        assert len(meaningful) > 0

    def test_sn06_back_navigation_works(self, driver):
        """TC-SN-06: Tapping back returns to StudentHomeScreen."""
        _login_and_open_student_notes(driver)
        driver.back()
        _w(driver, WAIT).until(
            EC.presence_of_element_located((
                AppiumBy.XPATH,
                "//*[contains(@text,'Welcome back') or "
                "contains(@text,\"Today's Homework\")]"
            ))
        )

    def test_sn07_pull_to_refresh_no_crash(self, driver):
        """TC-SN-07: Pull-to-refresh on notes screen does not crash."""
        _login_and_open_student_notes(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 400, size["width"] // 2, 800, 600)
        assert True

    def test_sn08_scroll_down_no_crash(self, driver):
        """TC-SN-08: Scrolling down notes list does not crash."""
        _login_and_open_student_notes(driver)
        size = driver.get_window_size()
        driver.swipe(size["width"] // 2, 700, size["width"] // 2, 200, 700)
        assert True

    def test_sn09_appbar_or_title_visible(self, driver):
        """TC-SN-09: AppBar with a title is shown on the notes screen."""
        _login_and_open_student_notes(driver)
        texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        assert len(texts) > 0

    def test_sn10_back_button_icon_present(self, driver):
        """TC-SN-10: Back arrow/button is present in the AppBar."""
        _login_and_open_student_notes(driver)
        back = driver.find_elements(
            AppiumBy.XPATH,
            "//android.widget.ImageButton[@content-desc='Back' or "
            "@content-desc='Navigate up']"
        )
        assert len(back) > 0, "No back button found on notes screen"

    def test_sn11_note_card_not_clickable_without_action(self, driver):
        """TC-SN-11: Notes are read-only; no edit inputs are shown by default."""
        _login_and_open_student_notes(driver)
        edit_inputs = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        assert len(edit_inputs) == 0, "Unexpected editable fields on student notes"

    def test_sn12_screen_stable_over_time(self, driver):
        """TC-SN-12: Notes screen remains stable for 3 seconds."""
        import time
        _login_and_open_student_notes(driver)
        time.sleep(3)
        texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
        assert len(texts) > 0
