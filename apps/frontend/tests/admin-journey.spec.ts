import { test, expect } from '@playwright/test';

test.describe('Admin Journey', () => {
  test('Admin can login and approve pending lab', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'admin@testly.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await page.waitForURL('**/admin**');
    await expect(page.locator('text=Admin Workspace')).toBeVisible();

    // Find pending lab review
    await expect(page.locator('text=Pending Lab (Demo)')).toBeVisible();
    await page.click('button:has-text("Approve")');
    
    // Check if status changed
    await expect(page.locator('text=Pending Lab (Demo)')).not.toBeVisible();
  });
});
