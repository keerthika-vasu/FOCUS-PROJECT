import pytest
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def test_login_fields_visibility(driver):
    """Verify that email, password, and sign-in buttons are visible on the login screen."""
    # Find email input (often matching the hint text in Flutter android rendering)
    email_el = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//*[@text='you@example.com' or @hint='you@example.com' or contains(@content-desc, 'Email')]"))
    )
    assert email_el is not None
    
    # Find password input
    pass_el = driver.find_element(By.XPATH, "//*[@text='••••••••' or @hint='••••••••' or contains(@content-desc, 'Password')]")
    assert pass_el is not None

def test_login_empty_credentials_error(driver):
    """Verify that clicking login with empty inputs displays an error message."""
    # Find Sign In button
    signin_btn = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//*[@text='Sign In' or @content-desc='Sign In' or contains(@content-desc, 'Sign In')]"))
    )
    signin_btn.click()
    
    # Verify error message shows up: 'Please enter email and password.'
    error_el = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.XPATH, "//*[contains(@text, 'Please enter email') or contains(@content-desc, 'Please enter email')]"))
    )
    assert error_el is not None

def test_navigate_to_signup(driver):
    """Verify that tapping 'Sign Up' navigates to the Signup screen."""
    signup_link = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//*[@text='Sign Up' or @content-desc='Sign Up' or contains(@content-desc, 'Sign Up')]"))
    )
    signup_link.click()
    
    # Verify we are on signup screen (e.g., checking for 'Confirm Password')
    confirm_pass_el = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//*[contains(@text, 'Confirm Password') or contains(@content-desc, 'Confirm Password')]"))
    )
    assert confirm_pass_el is not None
