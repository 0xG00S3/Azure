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
}
catch {
    Write-Error "Failed to get device code: $_"
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
        Write-Error "Authentication timeout occurred after $total seconds"
        return
    }

    try {
        $response = Invoke-RestMethod -UseBasicParsing -Method Post `
            -Uri "https://login.microsoftonline.com/Common/oauth2/token?api-version=1.0" `
            -Body $body `
            -ErrorAction Stop

        if ($response) {
            Write-Host "Authentication successful!"
            $continue = $false
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        try {
            $details = $_.ErrorDetails.Message | ConvertFrom-Json
            $continue = $details.error -eq "authorization_pending"
            
            if ($continue) {
                Write-Host "Waiting for device code authentication... ($($expires - $total) seconds remaining)"
            }
            else {
                Write-Error "Authentication failed: $($details.error_description)"
                return
            }
        }
        catch {
            Write-Error "Failed to process error response: $errorMsg"
            return
        }
    }
}

if ($response.access_token) {
    Write-Host "`nAccess token acquired successfully"
    # Output the access token
    $response.access_token

    # Store but don't display the refresh token
    $refreshToken = $response.refresh_token
}
else {
    Write-Error "No access token received in the response"
}
