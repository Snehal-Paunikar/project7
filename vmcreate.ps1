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
New-AzResourceGroup -Name $rg -Location $location

# Step 2: Create a virtual network in the resource group
New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg -Location $location -AddressPrefix $addressPrefixVNet

# Step 3: Create a subnet configuration for a virtual network
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $addressPrefixSubnet

# Step 4: Create a network security group in the resource group
New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -Location $location

# Step 5: Create a network interface for the VM
$subnetId = "/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName" # Ensure the subnet ID is correct
New-AzNetworkInterface -Name $nicName -ResourceGroupName $rg -Location $location -SubnetId $subnetId

# Step 6: Create a basic Ubuntu VM in the subnet with the network interface
$credential = Get-Credential # Prompt for VM credentials
New-AzVM -ResourceGroupName $rg -Location $location -Name $vmName -Credential $credential -Image "Ubuntu2204" -Size "Standard_D2ads_v6" -SubnetName $subnetName -VirtualNetworkName $vnetName
