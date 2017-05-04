<cfoutput>TestBox v#testBox.getVersion()#
---------------------------------------------------------------------------------
| Passed  | Failed  | Errored | Skipped | Time    | Bundles | Suites  | Specs   |
---------------------------------------------------------------------------------
| #headerCell("#results.getTotalPass()#")# | #headerCell("#results.getTotalFail()#")# | #headerCell("#results.getTotalError()#")# | #headerCell("#results.getTotalSkipped()#")# | #headerCell("#results.getTotalDuration()# ms")# | #headerCell(results.getTotalBundles())# | #headerCell(results.getTotalSuites())# | #headerCell(results.getTotalSpecs())# |
---------------------------------------------------------------------------------
<cfif hasLabels(results)>->[Labels Applied: #arrayToList( results.getLabels() )#]</cfif>
<cfloop array="#variables.bundleStats#" index="thisBundle">
=================================================================================
#thisBundle.path# (#thisBundle.totalDuration# ms) [Suites/Specs: #thisBundle.totalSuites#/#thisBundle.totalSpecs#]
[Passed: #thisBundle.totalPass#] [Failed: #thisBundle.totalFail#] [Errors: #thisBundle.totalError#] [Skipped: #thisBundle.totalSkipped#]
---------------------------------------------------------------------------------
<cfif !isSimpleValue( thisBundle.globalException )>
GLOBAL BUNDLE EXCEPTION
-> #thisBundle.globalException.type#:#thisBundle.globalException.message#:#thisBundle.globalException.detail#
---------------------------------------------------------------------------------
STACKTRACE
---------------------------------------------------------------------------------
#thisBundle.globalException.stacktrace#
---------------------------------------------------------------------------------
END STACKTRACE
---------------------------------------------------------------------------------
</cfif>

<cfloop array="#thisBundle.suiteStats#" index="suiteStats">
#genSuiteReport( suiteStats, thisBundle )#
</cfloop>
</cfloop>
---------------------------------------------------------------------------------
Legend: (P) = Passed, (-) = Skipped, (X) = Exception/Error, (!) = Failure
</cfoutput>


<cffunction name="getStatusBit" output="false">
	<cfargument name="status">
	<cfscript>
		switch( arguments.status ){
			case "failed" : { return "!"; }
			case "error" : { return "X"; }
			case "skipped" : { return "-"; }
			default : { return "+"; }
		}		
	</cfscript>
</cffunction>
<!--- Recursive Output --->
<cffunction name="genSuiteReport" output="false">
	<cfargument name="suiteStats">
	<cfargument name="bundleStats">
	<cfargument name="level" default=0>

<cfif arguments.bundleStats.totalFail + arguments.bundleStats.totalError eq 0>
	<cfreturn>
</cfif>

<cfset var tabs = repeatString( "    ", arguments.level )>

<cfsavecontent variable="local.report">
<cfoutput>

#tabs#(#getStatusBit( arguments.suiteStats.status )#)#arguments.suiteStats.name# #chr(13)#
<cfloop array="#arguments.suiteStats.specStats#" index="local.thisSpec">
<cfif ListFindNoCase("failed,exception", local.thisSpec.status) eq 0><cfcontinue></cfif>#repeatString( "    ", arguments.level+1 )#(#getStatusBit( local.thisSpec.status )#)#local.thisSpec.name# (#local.thisSpec.totalDuration# ms) #chr(13)#
<cfif local.thisSpec.status eq "failed">
	-> Failure: #local.thisSpec.failMessage##chr(13)#
	<!--- -> Failure Origin: #local.thisSpec.failorigin.toString()# #chr(13)##chr(13)# --->
</cfif>
	
<cfif local.thisSpec.status eq "error">
	-> Error: #local.thisSpec.error.message##chr(13)#
	-> Exception Trace: #local.thisSpec.error.stackTrace# #chr(13)##chr(13)#
</cfif>
</cfloop>

<cfif arrayLen( arguments.suiteStats.suiteStats )>
<cfloop array="#arguments.suiteStats.suiteStats#" index="local.nestedSuite">#genSuiteReport( local.nestedSuite, arguments.bundleStats, arguments.level+1 )#</cfloop>
</cfif>	

</cfoutput>
</cfsavecontent>

	<cfreturn local.report>
</cffunction>


<cffunction name="headerCell" output="false">
	<cfargument name="text">
	<cfreturn Left( arguments.text & RepeatString( " ", variables.HEADER_CELL_CHARS), variables.HEADER_CELL_CHARS)>
</cffunction>

<cffunction name="hasLabels" output="false">
	<cfargument name="results">
	<cfreturn arrayLen(arguments.results.getLabels())>
</cffunction>