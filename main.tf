
resource "azurerm_managed_disk" "my-managed-disk" {
  create_option        = "Empty"
  location             = "California"
  name                 = "my-managed-disk-1"
  resource_group_name  = "some-rg"
  storage_account_type = "Standard_LRS"
}
