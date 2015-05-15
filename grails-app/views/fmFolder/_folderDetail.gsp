<g:logMsg>folderDetail page</g:logMsg>

<%@ page import="annotation.*; org.transmart.biomart.*; com.recomdata.util.*; org.apache.commons.lang.StringUtils" %>

<script type="text/javascript">
    $j(document).ready(function() 
    {  
            <g:each var='jSONForGrid' status="gridCounter" in="${jSONForGrids}">
                  var dt${gridCounter}  = new dataTableWrapper('gridViewWrapper${gridCounter}', 'gridViewTable${gridCounter}', 'Title');
                   dt${gridCounter}.loadData(${jSONForGrids[gridCounter]});
          </g:each>
     

     });
    function openInAnalyze(accession, datasetExplorerPath) {
        var searchParam = {id: accession,
            display: 'Accession',
            keyword: accession,
            category: 'ACCESSION'};

        addSearchTerm(searchParam, false, true, datasetExplorerPath);
    }
</script>

<g:set var="overlayDiv" value="metaData_div" />

<div style="margin:10px;padding:10px;">
    <g:hiddenField name="parentId" value="${folder?.parentId}" />

    <div>
        <div style="float: right">
            <%-- Add buttons here depending on folder type --%>
                
            <sec:ifAnyGranted roles="ROLE_ADMIN">
                <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.PROGRAM.name())}">
                    <span name="${folder.id}" class="greybutton buttonicon addstudy">Add new study</span>
                    <span name="${folder.id}" class="greybutton buttonicon addfolder">Add new folder</span>
                </g:if>
                
                <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.STUDY.name())}">
                    <span name="${folder.id}" class="greybutton buttonicon addanalysis">Add new analysis</span>
                    <span name="${folder.id}" class="greybutton buttonicon addassay">Add new assay</span>
                    <span name="${folder.id}" class="greybutton buttonicon addfolder">Add new folder</span>
                </g:if>
                        
                <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.FOLDER.name()) ||
                              folder.folderType.equalsIgnoreCase(FolderType.ASSAY.name()) ||
                              folder.folderType.equalsIgnoreCase(FolderType.ANALYSIS.name())}">
                    <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.FOLDER.name()) &&
                                  folder.parent?.folderType.equalsIgnoreCase(FolderType.STUDY.name())}">
                        <span name="${folder.id}" class="greybutton buttonicon addanalysis">Add new analysis</span>
                    </g:if>
                    <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.FOLDER.name())}">
                        <g:logMsg>Upload files button</g:logMsg>
                        <span name="${folder.id}" class="greybutton buttonicon uploadfiles">Upload files</span>
                    </g:if>
                    <span name="${folder.id}" class="greybutton buttonicon addfolder">Add new folder</span>
                    <span name="${folder.id}" data-parent="${folder.parent?.id}" class="greybutton buttonicon deletefolder">
                        Delete this ${folder.folderType.toLowerCase()}</span>
                </g:if>
            </sec:ifAnyGranted>
        </div>
        <h3 class="rdc-h3">
            <g:if test="${folder?.hasProperty('folderName')}">
                        ${StringUtils.capitalize(folder?.folderType.toLowerCase())}: ${folder?.folderName}
            </g:if>
        </h3>
    </div>
    <g:if test="${bioDataObject?.hasProperty('description')}">
        <div class="description">
             <g:if test="${bioDataObject?.description?.length() > 325000}">
                         ${(bioDataObject?.description)?.substring(0,324000)}&nbsp;&nbsp;
                 <a href=# >...See more</a>
             </g:if>
             <g:else>
                 ${bioDataObject?.description}
             </g:else>
        </div>
        <div style="height:20px;"></div>
    </g:if>
    <g:elseif test="${bioDataObject?.hasProperty('longDescription')}">
        <div class="description">
            <g:if test="${bioDataObject?.longDescription?.length() > 325000}">
                        ${(bioDataObject?.longDescription)?.substring(0,324000)}&nbsp;&nbsp;
                <a href=# >...See more</a>
            </g:if>
            <g:else>
                        ${bioDataObject?.longDescription}
            </g:else>
        </div>
        <div style="height:20px;"></div>
    </g:elseif>

    <g:if test="${subjectLevelDataAvailable}">
        <center><div
                class="messagebox">Subject-level data is available for this study. <a
                    href="#"
                    onclick="openInAnalyze('${bioDataObject.accession}', '${createLink(controller:'datasetExplorer', action:'index')}');">Open in Analyze view</a>
                </div>
            </center>
        <br/><br/>
    </g:if>

    <g:if test="${metaDataTagItems && metaDataTagItems.size()>0}">
        <div><h4 class="rdc-h4">Associated Tags</h4></div>
        <table class="details-table">
            <thead>
                <tr>                
                    <th class="columnheader">Property</th>
                    <th class="columnheader">
                        Value
                        <%-- Restrict edits to administrators --%>
                        <sec:ifAnyGranted roles="ROLE_ADMIN">
                                  <img align="right" class="editmetadata" name="${folder?.id}" src="${resource(dir:'images', file:'pencil.png')}"/>
                        </sec:ifAnyGranted>
                    </th>
                </tr>
            </thead>
            <tbody>
                <g:each in="${metaDataTagItems}" status="i" var="amTagItem">
                    <g:if test="${amTagItem.viewInGrid}">
                        <tr class='details-row ${(i % 2) == 0 ? 'odd' : 'even'}'>
                        <!-- TODO: If active -->
            
                            <td valign="top" align="right" class="columnname" width="20%">${amTagItem.displayName}</td>
                            <td valign="top" align="left" class="columnvalue" width="30%">
            
                                <!-- FIXED -->
                                <g:if test="${amTagItem.tagItemType == 'FIXED'  &&
                                              amTagItem.tagItemAttr!=null?bioDataObject?.hasProperty(amTagItem.tagItemAttr):false}" >
                                    <g:set var="_fieldValue" value="${fieldValue(bean:bioDataObject,field:amTagItem.tagItemAttr)}"/>
                                    <g:if test="${amTagItem.tagItemSubtype == 'PICKLIST'}">
                                        <%-- Split multiple values by pipe --%>
                                        <g:set var="terms" value="${_fieldValue.split('\\|')}"/>
                                 
                                        <g:each in="${terms}" var="term" status="t">
                                            <g:set var="bioDataId" value="${BioData.find('from BioData where uniqueId=?',[term])?.id}"/>
                                            <g:if test="${t > 0}"><br/>
                                            </g:if>
                                            <g:if test="${bioDataId}">
                                                ${ConceptCode.find('from ConceptCode where id=?', bioDataId).codeName}
                                            </g:if>
                                            <g:else>
                                                ${term}
                                            </g:else>
                                        </g:each>
                                    </g:if>
                                    <g:elseif test="${amTagItem.tagItemSubtype == 'MULTIPICKLIST'}">
                                        <%-- Split multiple values by pipe --%>
                                        <g:set var="terms" value="${_fieldValue.split('\\|')}"/>
                                 
                                        <g:each in="${terms}" var="term" status="t">
                                            <g:set var="bioDataId" value="${BioData.find('from BioData where uniqueId=?',[term])?.id}"/>
                                            <g:if test="${t > 0}"><br/></g:if>
                                            <g:if test="${bioDataId}">
                                                ${ConceptCode.find('from ConceptCode where id=?', bioDataId).codeName}
                                            </g:if>
                                            <g:else>
                                                ${term}
                                            </g:else>
                                        </g:each>
                                    </g:elseif>
                                    <g:else>
                                                ${_fieldValue}
                                    </g:else>
                                </g:if>
                                <g:else>
                                    <g:set var="tagValues" value="${AmTagDisplayValue.findAllDisplayValue(folder.getUniqueId(),amTagItem.id)}"/>
                                    <g:if test="${tagValues!=null}">
                                        <g:each var="tagValue" status="k" in="${tagValues}">
                                            <g:if test="${k > 0 && tagValue.displayValue}"><br/>
                                            </g:if>
                                            <g:createTagItemValue tagItem="${amTagItem}" tagValue="${tagValue}"/>
                                        </g:each>
                                    </g:if>
                                </g:else>

                            </td>
                        </tr>
                    </g:if>
                </g:each>
            </tbody>    
        </table>
        <span></span>
    </g:if> 
                    
                   
    <div style="height:20px;"></div>
    <g:if test="${folder?.hasProperty('fmFiles') && null!=folder?.fmFiles && folder?.fmFiles.size()>0}">   
        <div class="dataTables_wrapper">
            <div class="gridTitle">Associated Files</div>
            <div id="files-table">
                <g:render template="filesTable" plugin="folderManagement" model="[folder:folder]"/>
            </div>
        </div>
    </g:if>

    <span></span>



    <g:each var='jSONForGrid' status="divCounter" in="${jSONForGrids}">
        <div style="height:20px;"></div>
        <div>
            <div id='gridViewWrapper${divCounter}'>
            </div>        
        </div>
    </g:each>
         
    <%-- If this is an analysis, provide a div for analysis data --%>
    <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.ANALYSIS.name())}">
        <center><div id="partialanalysiswarning" class="messagebox" style="display: none;">
            Displaying results from the first 1000 rows<span id="analysisgenefilteredwarning" style="display: none;">, filtered by the gene search</span>.
            <a id="loadfullanalysis" href="#" onclick="updateAnalysisData(${bioDataObject.id}, true)">Load all X</a></div></center>
        <div id="gridViewWrapperAnalysis" name="${bioDataObject.id}" class="ajaxloading">
        </div>
        <script type="text/javascript">
        $j(document).ready(function() 
        {
                $j.ajax({
                        url:analysisDataURL,
                        data: {id: ${bioDataObject.id}},
                        success: function(response) {
                                jQuery('#gridViewWrapperAnalysis').removeClass('ajaxloading');
                                if (response.rowCount > 0) {
                                          var dtAnalysis  = new dataTableWrapper('gridViewWrapperAnalysis', 'gridViewTableAnalysis', 'Title', [[2, "asc"]], 25);
                                           dtAnalysis.loadData(response);
                                }
                                   if (response.rowCount > 1000) {
                                           jQuery('#loadfullanalysis').text('Load all ' + response.rowCount + ' rows')
                                           jQuery('#partialanalysiswarning').show();
                                   }
                                   if (response.filteredByGenes) {
                                           jQuery('#analysisgenefilteredwarning').show();
                                   }
                        }
                });
        });
        </script>
    </g:if>
         
    <!--  overlay div  -->

    <g:overlayDiv divId="${overlayDiv}" />
</div>
 
 <!-- background-color:#9CA4E4;  -->   
    
 
