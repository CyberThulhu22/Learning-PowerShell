<#
.SYNOPSIS
        <Brief Description>

.DESCRIPTION
        <Full Description>

.PARAMETER <First-Parameter>
        <First Parameter Description>

.PARAMETER <Second-Parameter>
        <Second Parameter Description>

.INPUTS
        <Inputs>

.OUTPUTS
        <Outputs>

.EXAMPLE
        Template-Project.ps1 [-First-Parameter <Argument>] [-Second-Parameter <Argument>] [-Output <Path/To/OutFile>] [-Verbose]

.LINK
        hxxtp://www.template_reference_link.com/

.NOTES
        NAME:    PS-PortScan.ps1
        VERSION: 1.0.0
        AUTHOR:  Jesse Leverett (CyberThulhu)
        STATUS:  Mostly Complete
        TO-DO:   Finish Cleaning Script

        COPYRIGHT © 2022 Jesse Leverett
#>

Function Invoke-Template {
    [CmdletBinding(DefaultParameterSetName = "Template")]
    Param (
        # Parameter help description
        [Parameter( Mandatory, 
        ParameterSetName="First_Parameter", 
        HelpMessage="Help Message",
        Position=0 )]
        [ValidateLength( 1, 10 )]
        [Alias( "FP", "First" )]
        [String[]]
        $First_Parameter,

        # Parameter help description
        [Parameter( Mandatory, 
        ParameterSetName="Second_Parameter_Set_One", 
        HelpMessage="Help Message",
        Position=0 )]
        [ValidatePattern( "[0-9][0-9][0-9][0-9]" )]
        [Alias( "SP", "Second" )]
        [String[]]
        $Second_Parameter,
        
        # Parameter help description
        [Parameter( Mandatory, 
        ParameterSetName="Second_Parameter_Set_One", 
        HelpMessage="Help Message",
        Position=0 )]
        [ValidatePattern( "[0-9][0-9][0-9][0-9]" )]
        [Alias( "TP", "Third" )]
        [String[]]
        $Third_Parameter
    )


}