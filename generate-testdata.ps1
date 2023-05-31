# Generate some sample data for a database practice.
# sample data is an imaginary library card. 
# it'll have all the same details as a passport and visa....reasons unrelated.

function Generate-Number($digits){
    $output = ""
    for($i = 0; $i -lt $digits; $i++)
    {
        if($i -eq 0) { $output = $output + [string](Get-Random -Minimum 1 -Maximum 9) }
        else{ $output = $output + [string](Get-Random -Minimum 0 -Maximum 9) }
    }
    return $output
}

function Roll-D20(){
    return Get-Random -Minimum 1 -Maximum 20
}

function Get-RandomDateInThePast($years)
    {
        $rdays = Get-Random -Minimum 1 -Maximum 350
        $rmonth = Get-Random -Minimum 1 -Maximum 12

        if($years -gt 0){ $ryear = Get-Random -Minimum 0 -Maximum $years }
        else{ $ryear = $years }
        
        $date = Get-Date
        $date = ($date).AddYears(-$ryear)
        $date = ($date).AddMonths(-$rmonth)
        $date = ($date).Adddays(-$rdays)
        return Get-Date $date -Format "MM/dd/yyyy"   
    }

$og_excel = @(Import-Csv .\sample-data-table.csv)

$country_list = import-csv .\Country_key.csv
$Cou_Hash = @{}
foreach($country in $country_list )
{
    $Cou_Hash[$country.No] += $country.Country
}

$nametable = @(Import-Csv .\random_names.csv)

for($i = 0; $i -lt 29; $i++)
{
    $temp_obj = $og_excel[0]

    #country
    $cou_no = [string](Get-Random -Minimum 0 -Maximum 23)
    $temp_obj."Country" = $country_list[$cou_no].Country

    #Surname
    $temp_obj."Surname" = $nametable[$i].Surname
    $temp_obj."Given Name" = $nametable[$i].Given
    
    #PPT number
    $temp_obj."ID number" = Generate-Number(9)

    #"Issue Date" 
    $temp_obj."Issue Date" = Get-Date -Date (Get-RandomDateInThePast(9)) -Format "dd MMM yyyy"

    #ID expiration Date
    $temp_obj."Expiration Date" = Get-Date -Date (((Get-Date ($temp_obj.'Issue Date')).AddYears(10)).AddDays(-1)) -Format "dd MMM yyyy"

    #Visa issuing city
    $temp_obj."place of issue" = $country_list[$cou_no].Capital

    #place of birth 
    if( (Roll-D20) -lt 11){ $temp_obj."place of birth" = $($temp_obj."place of issue") }
    else{ $temp_obj."place of birth" = $country_list[$cou_no].Other }
        

    #Gender
    $rgender = Roll-D20
    if($rgender -le 9){ $temp_obj."gender" = [char]"F" }
    if($rgender -gt 9 -and $rgender -le 18 ){ $temp_obj."gender" = [char]"M" }
    if($rgender -gt 18){ $temp_obj."gender" = [char]"X" }
    
    #Passport Type (diplomatic? or something?)
    $temp_obj."type" = [char]"P"
    
    #Visa yes /no - sets the rest in here.
    # if(Visa) set the rest. Else set to N/A
    if( (Roll-D20) -lt 16 ){
        $temp_obj."Visa" = "yes"
        
        #Visa Number 
        $temp_obj."Visa No" = ( Generate-Number(9) )  
        
        #boolean, temporary visa
        if( $(Roll-D20) -lt 10){ $temp_obj."Temp" = [bool]$false}
        else { $temp_obj."Temp" = [bool]$true}

            #date of VISA issue...that's a confusing name.
        $issue_year = Roll-D20
        $issue_year = [int]($issue_year / 6)
        $temp_obj."date of issue" = Get-date -Date (Get-RandomDateInThePast($issue_year)) -Format "yyyy.MM.dd"

        #Visa Expiration....these names are bad
        if($temp_obj.Temp -eq $true){
            $temp_obj."Expiration" = Get-Date -Date ((Get-Date ($temp_obj."date of issue")).AddMonths(3)).AddDays(-1) -Format "yyyy.MM.dd"
        }else{
            $temp_obj."Expiration" = Get-Date -Date ((Get-Date ($temp_obj."date of issue")).AddYears(3)).AddDays(-1) -Format "yyyy.MM.dd"
        }

        #not f'ing with it anymore
        $temp_obj."Visa Place of issue" = "江苏“
        $temp_obj."Observations" = "无/None"        
        }
    else{
        $temp_obj."Visa" = "no"
        $temp_obj."Visa No" = "N/A" 
        $temp_obj."date of issue" = "N/A"
        $temp_obj."Temp" = [bool]$false
        $temp_obj."Expiration" = "N/A"
        $temp_obj."Visa Place of issue" = "N/A“
        $temp_obj."Observations" = "N/A"        
        }

    Export-Csv -Path .\Visa-Test-Data-$($runcount).csv -Append -InputObject $temp_obj -Encoding UTF8 -NoTypeInformation
}

Write-Host "done" -ForegroundColor DarkGreen
Invoke-Item .\Visa-Test-Data-$($runcount).csv
$runcount += 1