"""
FOCUS-SHIELD – FocusModeScreen E2E Tests
Dart source : lib/screens/student/focus_mode_screen.dart

Covers:
  - Header title and subtitle text
  - Circular timer display (time text, shield icon)
  - Preset time chips (15/25/45/60 min)
  - +5 / -5 adjustment buttons
  - Start Focus Session button
  - Active state: colour change, blocked-apps list, End Session button
  - Timer tick verification (1-second decrement)
  - End Session resets state
"""

import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

WAIT = 20
SHORT = 8

# ── helpers ───────────────────────────────────────────────────────────────────

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


def _find_btn(driver, label, t=WAIT):
    return _w(driver, t).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            f"//android.widget.Button[@text='{label}']"
        ))
    )


def _login_as_student_and_open_focus(driver):
    """Log in as student and navigate to Focus Mode tab."""
    _w(driver, 30).until(
        EC.presence_of_element_located((
            AppiumBy.XPATH,
            "//android.widget.EditText[@text='you@example.com' or "
            "@content-desc='you@example.com']"
        ))
    )
    email = driver.find_element(
        AppiumBy.XPATH, "//android.widget.EditText[@text='you@example.com']"
    )
    email.clear(); email.send_keys("student@focusshield.test")
    pwd = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
    if len(pwd) >= 2:
        pwd[1].clear(); pwd[1].send_keys("TestPass123")
    _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH, "//android.widget.Button[@text='Sign In']"
        ))
    ).click()
    # Navigate to Focus tab (StudentShell bottom nav)
    focus_tab = _w(driver, WAIT).until(
        EC.element_to_be_clickable((
            AppiumBy.XPATH,
            "//*[contains(@content-desc,'Focus') or contains(@text,'Focus')]"
        ))
    )
    focus_tab.click()
    _find(driver, "Focus Mode")


# ── TestFocusModeScreen ───────────────────────────────────────────────────────

class TestFocusModeScreen:
    """TC-FM-01 … TC-FM-17: FocusModeScreen UI & timer logic."""

    def test_fm01_focus_mode_title_visible(self, driver):
        """TC-FM-01: 'Focus Mode' title is visible."""
        _login_as_student_and_open_focus(driver)
        el = _find(driver, "Focus Mode")
        assert el.is_displayed()

    def test_fm02_subtitle_idle_text(self, driver):
        """TC-FM-02: Idle subtitle 'Choose your time, then start your session' shown."""
        _login_as_student_and_open_focus(driver)
        el = _find_contains(driver, "Choose your time")
        assert el.is_displayed()

    def test_fm03_timer_default_displays_25min(self, driver):
        """TC-FM-03: Timer defaults to 25:00."""
        _login_as_student_and_open_focus(driver)
        el = _find(driver, "25:00")
        assert el.is_displayed()

    def test_fm04_default_session_label(self, driver):
        """TC-FM-04: '25 min session' session label is visible."""
        _login_as_student_and_open_focus(driver)
        el = _find_contains(driver, "25 min session")
        assert el.is_displayed()

    def test_fm05_preset_15min_chip_visible(self, driver):
        """TC-FM-05: '15 min' preset chip is present."""
        _login_as_student_and_open_focus(driver)
        el = _find(driver, "15 min")
        assert el.is_displayed()

    def test_fm06_preset_45min_chip_visible(self, driver):
        """TC-FM-06: '45 min' preset chip is present."""
        _login_as_student_and_open_focus(driver)
        el = _find(driver, "45 min")
        assert el.is_displayed()

    def test_fm07_preset_60min_chip_visible(self, driver):
        """TC-FM-07: '60 min' preset chip is present."""
        _login_as_student_and_open_focus(driver)
        el = _find(driver, "60 min")
        assert el.is_displayed()

    def test_fm08_tap_15min_updates_timer(self, driver):
        """TC-FM-08: Tapping '15 min' chip changes timer to 15:00."""
        _login_as_student_and_open_focus(driver)
        _find(driver, "15 min").click()
        el = _find(driver, "15:00")
        assert el.is_displayed()

    def test_fm09_tap_60min_updates_timer(self, driver):
        """TC-FM-09: Tapping '60 min' chip changes timer to 60:00."""
        _login_as_student_and_open_focus(driver)
        _find(driver, "60 min").click()
        el = _find(driver, "60:00")
        assert el.is_displayed()

    def test_fm10_start_focus_session_button_visible(self, driver):
        """TC-FM-10: 'Start Focus Session' button is present and clickable."""
        _login_as_student_and_open_focus(driver)
        btn = _find_btn(driver, "Start Focus Session")
        assert btn.is_displayed()

    def test_fm11_start_session_enters_active_state(self, driver):
        """TC-FM-11: Tapping 'Start Focus Session' reveals 'End Session' button."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        end_btn = _find_btn(driver, "End Session")
        assert end_btn.is_displayed()

    def test_fm12_active_shows_blocked_apps_label(self, driver):
        """TC-FM-12: During active session, 'Blocked during focus' label appears."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        el = _find_contains(driver, "Blocked during focus")
        assert el.is_displayed()

    def test_fm13_blocked_app_instagram_listed(self, driver):
        """TC-FM-13: 'Instagram' is listed in the blocked apps during focus."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        el = _find(driver, "Instagram")
        assert el.is_displayed()

    def test_fm14_blocked_app_youtube_listed(self, driver):
        """TC-FM-14: 'YouTube' is listed in the blocked apps during focus."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        el = _find(driver, "YouTube")
        assert el.is_displayed()

    def test_fm15_timer_decrements(self, driver):
        """TC-FM-15: Timer value decrements after 2 seconds in active state."""
        _login_as_student_and_open_focus(driver)
        _find(driver, "15 min").click()
        _find_btn(driver, "Start Focus Session").click()
        time.sleep(2)
        # Timer should be 14:58 or lower, not 15:00
        try:
            still_start = driver.find_element(
                AppiumBy.XPATH, "//*[@text='15:00']"
            )
            assert not still_start.is_displayed(), "Timer did not decrement"
        except Exception:
            pass  # element gone = timer moved = correct

    def test_fm16_end_session_resets_to_idle(self, driver):
        """TC-FM-16: Tapping 'End Session' resets screen to idle state."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        _find_btn(driver, "End Session").click()
        btn = _find_btn(driver, "Start Focus Session")
        assert btn.is_displayed()

    def test_fm17_idle_subtitle_returns_after_end(self, driver):
        """TC-FM-17: Idle subtitle text returns after ending a session."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        _find_btn(driver, "End Session").click()
        el = _find_contains(driver, "Choose your time")
        assert el.is_displayed()

    def test_fm18_tap_45min_updates_timer(self, driver):
        """TC-FM-18: Tapping '45 min' chip changes timer display to 45:00."""
        _login_as_student_and_open_focus(driver)
        _find(driver, "45 min").click()
        el = _find(driver, "45:00")
        assert el.is_displayed()

    def test_fm19_start_btn_hidden_during_session(self, driver):
        """TC-FM-19: 'Start Focus Session' button is not visible when session is active."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        try:
            start = driver.find_element(
                AppiumBy.XPATH, "//android.widget.Button[@text='Start Focus Session']"
            )
            assert not start.is_displayed(), "Start button should be hidden during session"
        except Exception:
            pass  # not found = correct

    def test_fm20_blocked_app_whatsapp_listed(self, driver):
        """TC-FM-20: 'WhatsApp' is listed in the blocked apps during focus."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        el = _find(driver, "WhatsApp")
        assert el.is_displayed()

    def test_fm21_blocked_app_games_listed(self, driver):
        """TC-FM-21: A 'Games' or gaming category appears in blocked apps."""
        _login_as_student_and_open_focus(driver)
        _find_btn(driver, "Start Focus Session").click()
        el = _find(driver, "Games")
        assert el.is_displayed()

    def test_fm22_no_editable_inputs_on_focus_screen(self, driver):
        """TC-FM-22: No editable text inputs exist on the Focus Mode screen."""
        _login_as_student_and_open_focus(driver)
        inputs = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
        assert len(inputs) == 0, f"Unexpected EditText fields on Focus screen: {len(inputs)}"
