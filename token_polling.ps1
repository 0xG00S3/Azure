# Client ID for Azure PowerShell
$clientId = "d3590ed6-52b3-4102-aeff-aad2292ab01c"
$resource = "https://graph.microsoft.com"

# Step 1: Request the device code
$deviceCodeRequestParams = @{
    Method = "POST"
    Uri    = "https://login.microsoftonline.com/Common/oauth2/devicecode"
    Body   = @{
        resource   = $resource
        client_id = $clientId
    }
}

try {
    Write-Host "Requesting device code..."
    $authResponse = Invoke-RestMethod @deviceCodeRequestParams
    Write-Host "`nAuthentication URL: $($authResponse.verification_url)"
    Write-Host "User Code: $($authResponse.user_code)`n"
    Write-Host "Please visit the authentication URL, enter the code above, and sign in.`n"
    Write-Host "Debug: Full auth response:"
    $authResponse | ConvertTo-Json | Write-Host
}
catch {
    Write-Error "Failed to get device code. Details:"
    Write-Error $_.Exception.Message
    if ($_.ErrorDetails) {
        Write-Error "Error Details: $($_.ErrorDetails.Message)"
    }
    return
}

# Initialize variables for token polling
$total = 0
$response = ""
$continue = $true
$interval = $authResponse.interval
$expires = $authResponse.expires_in

$body = @{
    "client_id"  = $clientId
    "grant_type" = "urn:ietf:params:oauth:grant-type:device_code"
    "code"       = $authResponse.device_code
    "resource"   = $resource
}

Write-Host "Starting token polling..."

while ($continue) {
    Start-Sleep -Seconds $interval
    $total += $interval

    if ($total -gt $expires) {
        Write-Error "Timeout occurred"
        Write-Error "Total time elapsed: $total seconds"
        return
    }

    try {
        $response = Invoke-RestMethod -UseBasicParsing -Method Post `
            -Uri "https://login.microsoftonline.com/Common/oauth2/token?api-version=1.0" `
            -Body $body `
            -ErrorAction SilentlyContinue

    }
    catch {
        try {
            $details = $_.ErrorDetails.Message | ConvertFrom-Json
            $continue = $details.error -eq "authorization_pending"
            Write-Host $details.error

            if (!$continue) {
                Write-Error "Authentication failed:"
                Write-Error $details.error_description
                Write-Error "Full error details: $($details | ConvertTo-Json)"
                return
            }
        }
        catch {
            Write-Error "Failed to process error response:"
            Write-Error $_.Exception.Message
            if ($_.Exception.Response) {
                Write-Error "Status: $($_.Exception.Response.StatusCode.value__) $($_.Exception.Response.StatusDescription)"
            }
            return
        }
    }

    if ($response) {
        Write-Host "Token received successfully!"
        break
    }
}

# Output the access token
if ($response.access_token) {
    Write-Host "Access token details:"
    Write-Host "Token type: $($response.token_type)"
    Write-Host "Expires in: $($response.expires_in) seconds"
    $response.access_token
}
else {
    Write-Error "No access token in response"
    Write-Error "Full response:"
    $response | ConvertTo-Json | Write-Error
}
