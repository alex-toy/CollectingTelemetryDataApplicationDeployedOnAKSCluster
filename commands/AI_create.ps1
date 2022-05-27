"###############################################################"
"Now running : " + $MyInvocation.MyCommand.Path
"###############################################################"


################################################################
# To access the preview Application Insights Azure CLI commands, you first need to run:
# az extension add -n application-insights


################################################################
# Variables
$Global:AIName = "alexeiai"
$Global:BAApplicationName = "alexeibaa"



################################################################
"CREATE AN APPLICATION INSIGHT :"

az monitor app-insights component create `
    --resource-group $RGName `
    --app $AIName `
    --location $RGLocation `
    # [--application-type]
    # [--kind]
    # [--tags]






