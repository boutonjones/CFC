<cfcomponent hint="Functions for interacting with the keyContacts table which is the xref table for maintaining Advisor's key contacts (i.e. the A List)"> 

    <!--- All proprietary information has been removed or replaced. --->
    
    <!--- *** START variable declarations *** --->
    
    <!--- *** END variable declarations *** --->
    
    <cffunction name="GetAgentName" returntype="query" hint="Look Up Agent's Name and Contact Information"> 
    	<cfargument name="AgentID" type="numeric" default="0">
        <cfquery datasource="cdb" name="qryGetAgentName">
            SELECT FirstName, LastName, Contact, Phone, Email, Address, City, State, Zip, ZipPlus
            FROM tblAgents
            WHERE AgentID = #AgentID#;
        </cfquery>
        <cfreturn qryGetAgentName>
    </cffunction>
    
    <cffunction name="getXref_Agents_Customers" returntype="query" hint="Search the xref_Agents_Customers table.  If the Agent's AgentID is passed, search by the Agent's AgentID.  Otherwise list all."> 
    	<cfargument name="AgentID" type="numeric" required="false">
		<cfquery datasource="cdb" name="qryGetxref_Agents_Customers">
		    SELECT tblCustomers.CustomerID
				, tblCustomers.FullName
				, tblCustomers.Email
				, tblCustomers.Ixnay 
				<cfif NOT isDefined("AgentID")>, xref_Agents_Customers.AgentID</cfif>
		    FROM tblCustomers JOIN xref_Agents_Customers 
		        ON tblCustomers.CustomerID = xref_Agents_Customers.CustomerID
		    <cfif isDefined("userid")>WHERE xref_Agents_Customers.AgentID = #AgentID#</cfif>
		    ORDER BY <cfif NOT isDefined("AgentID")>xref_Agents_Customers.AgentID, </cfif>
				tblCustomers.LastName
				, tblCustomers.FirstName
		    LIMIT 110;
		</cfquery>
        <cfreturn qryGetXref_Agents_Customers>
    </cffunction>
    
	<cffunction name="IsKeyContact" returntype="numeric" hint="identify whether a specific Customer is in a specific Agent's A List (i.e. a Key Contact for the Agent)"> 
		<!--- SYNTAX: <cfif IsKeyContact> in list <cfelse> not in list </cfif> --->
		<cfargument name="CustomerID" type="numeric" required="true">
		<cfargument name="AgentID" type="numeric" required="true">
		<cfquery name="qryIsKeyContact" datasource="CDB">
			SELECT COUNT(1) AS isKeyContact 
			FROM xref_Agents_Customers 
			WHERE xref_Agents_Customers.CustomerID = #CustomerID#
			    AND xref_Agents_Customers.AgentID = #AgentID#;
		</cfquery>
		<cfreturn qryIsKeyContact.isKeyContact>
	</cffunction>
	
	<cffunction name="addKeyContact" returntype="void" hint="Add record to xref_Agents_Customers table consisting of Agent's AgentID and Customer's CustomerID." >
        <cfargument name="AgentID" type="numeric" required="true">
        <cfargument name="ContactID" type="numeric" required="true">
		<cfquery datasource="CDB">
			INSERT INTO xref_Agents_Customers (AgentID, CustomerID) 
            VALUES (#AgentID#, #CustomerID#);
		</cfquery>
        <cfreturn>
	</cffunction>
	
    <cffunction name="DeleteKeyContact" returntype="void" hint="Remove either a single record or multiple records from the xref_Agents_Customers table (but never remove all the records.)"> 
     	<cfargument name="CustomerIDsingle" type="numeric" required="false" hint="Pass the URL.CustomerID"> 
		<cfargument name="CustomerIDlist" type="any" required="false" hint="Pass the list FORM.FIELDNAMES"> 
        <cfquery datasource="cdb">
            DELETE 
            FROM xref_Agents_Customers  
            WHERE 
            	<cfif isDefined("CustomerIDsingle")>
					CustomerID = #CustomerID#;
				<cfelseif isDefined("CustomerIDlist")>
					CustomerID IN (#CustomerIDlist#);
				<cfelse>
				    /* If NO CustomerID values are passed, DON'T delete any records! */
					0 = 1;
				</cfif>
        </cfquery>
        <cfreturn>
    </cffunction>  
	
    <cffunction name="today" returntype="date" hint="Return today's date"> 
        <cfreturn Now()>
    </cffunction>
    
    <cffunction name="OnMissingMethod" access="public" returntype="any" output="false" 
        hint="If an application calls a function that is not defined in the CFC, ColdFusion calls the onMissingMethod function and passes it the requested method’s name and arguments.  Code originally borrowed from Ben Nadel">
        <cfargument name="MissingMethodName" type="string" required="true" hint="The name of the missing method." />
        <cfargument name="MissingMethodArguments" type="struct" required="true"
            hint="The arguments that were passed to the missing method. This might be a named argument set or a numerically indexed set." />
        <cfdump var="#ARGUMENTS#" label="Missing Method Arguments" />
        <cfabort>
        <cfreturn>
    </cffunction>

</cfcomponent>
