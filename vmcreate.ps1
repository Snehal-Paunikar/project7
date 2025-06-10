# To resolve the question of creating a basic Ubuntu VM on Azure

# REGION OF VARIABLES
$rg = 'MyResourceGroup'
$location = 'East US'
$vnetName = 'MyVirtualNetwork'
$subnetName = 'MySubnet'
$nsgName = 'MyNSG'
$nicName = 'MyNetworkInterface'
$vmName = 'MyUbuntuVMgit1'
$addressPrefixVNet = '10.0.0.0/16'
$addressPrefixSubnet = '10.0.1.0/24'
$subscriptionId = 'bd44ed4c-c242-4fb8-916c-82e4c122d991' # Specify your subscription ID

# Step 1: Create a new resource group
# New-AzResourceGroup -Name $rg -Location $location
if (-not (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $rg -Location $location
} else {
    Write-Output "Resource group '$rg' already exists. Skipping creation."
}

# Step 2: Create a virtual network in the resource group
# New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg -Location $location -AddressPrefix $addressPrefixVNet
if (-not (Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg -ErrorAction SilentlyContinue)) {
    New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg -Location $location -AddressPrefix $addressPrefixVNet
} else {
    Write-Output "Virtual Network '$vnetName' already exists. Skipping creation."
}

# Step 3: Create a subnet configuration for a virtual network
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $addressPrefixSubnet

# Step 4: Create a network security group in the resource group
# New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -Location $location
if (-not (Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -ErrorAction SilentlyContinue)) {
    New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -Location $location
} else {
    Write-Output "Network Security Group '$nsgName' already exists. Skipping creation."
}

# Step 5: Create a network interface for the VM
# $subnetId = "/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" # Ensure the subnet ID is correct
# New-AzNetworkInterface -Name $nicName -ResourceGroupName $rg -Location $location -SubnetId $subnetId
$subnetId = "/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName"

if (-not (Get-AzNetworkInterface -Name $nicName -ResourceGroupName $rg -ErrorAction SilentlyContinue)) {
    New-AzNetworkInterface -Name $nicName -ResourceGroupName $rg -Location $location -SubnetId $subnetId
} else {
    Write-Output "Network Interface '$nicName' already exists. Skipping creation."
}

# Step 6: Create a basic Ubuntu VM in the subnet with the network interface
# $credential = Get-Credential # Prompt for VM credentials
# New-AzVM -ResourceGroupName $rg -Location $location -Name $vmName -Credential $credential -Image "Ubuntu2204" -Size "Standard_D2ads_v6" -SubnetName $subnetName -VirtualNetworkName $vnetName
# Set the username for the VM (can be hardcoded or passed as env variable)
$username = "azureuser"

# Get the plain password from environment variable VM_PASSWORD
$passwordPlain = $env:VM_PASSWORD

if (-not $passwordPlain) {
    throw "VM_PASSWORD environment variable is not set!"
}

# Convert plain password to secure string
$securePassword = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

# Create PSCredential object
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Create the VM with credential
New-AzVM -ResourceGroupName $rg -Location $location -Name $vmName -Credential $credential -Image "Ubuntu2204" -Size "Standard_D2ads_v6" -SubnetName $subnetName -VirtualNetworkName $vnetName
