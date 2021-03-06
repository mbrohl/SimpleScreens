<#--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#-- See the mantle.ledger.LedgerReportServices.run#BalanceSheet service for data preparation -->

<#assign showDetail = (detail! == "true")>
<#assign showDiff = (timePeriodIdList?size == 2)>
<#assign showPercents = (percents! == "true")>
<#assign showCharts = (charts! == "true")>
<#assign currencyFormat = currencyFormat!"#,##0.00">
<#assign percentFormat = percentFormat!"0.0%">
<#assign backgroundColors = ['rgba(92, 184, 92, 0.5)','rgba(91, 192, 222, 0.5)','rgba(240, 173, 78, 0.5)','rgba(217, 83, 79, 0.5)',
'rgba(60, 118, 61, 0.5)','rgba(49, 112, 143, 0.5)','rgba(138, 109, 59, 0.5)','rgba(169, 68, 66, 0.5)',
'rgba(223, 240, 216, 0.6)','rgba(217, 237, 247, 0.6)','rgba(252, 248, 227, 0.6)','rgba(242, 222, 222, 0.6)']>

<#macro showClass classInfo depth showLess=false>
    <#-- skip classes with nothing posted -->
    <#if (classInfo.totalPostedNoClosingByTimePeriod['ALL']!0) == 0><#return></#if>
    <#if showLess><#assign negMult = -1><#else><#assign negMult = 1></#if>
    <tr>
        <td style="padding-left: ${(depth-1) * 2}.3em;">${ec.l10n.localize(classInfo.className)}<#if showLess && depth == 1> (${ec.l10n.localize("less")})</#if></td>
        <#if (timePeriodIdList?size > 1)>
            <td class="text-right text-mono" style="padding-right:${depth}em;">${ec.l10n.format((classInfo.postedNoClosingByTimePeriod['ALL']!0)*negMult, currencyFormat)}</td>
        </#if>
        <#list timePeriodIdList as timePeriodId>
            <td class="text-right text-mono" style="padding-right:${depth}em;">${ec.l10n.format((classInfo.postedNoClosingByTimePeriod[timePeriodId]!0)*negMult, currencyFormat)}</td>
            <#if showPercents>
                <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                <#assign currentAmt = (classInfo.postedNoClosingByTimePeriod[timePeriodId]!0)*negMult>
                <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
            </#if>
        </#list>
        <#if showDiff>
            <td class="text-right text-mono" style="padding-right:${depth}em;">${ec.l10n.format(((classInfo.postedNoClosingByTimePeriod[timePeriodIdList[1]]!0) - (classInfo.postedNoClosingByTimePeriod[timePeriodIdList[0]]!0))*negMult, currencyFormat)}</td>
        </#if>
    </tr>
    <#list classInfo.glAccountInfoList! as glAccountInfo>
        <#if showDetail>
            <tr>
                <td style="padding-left: ${(depth-1) * 2 + 3}.3em;"><#if accountCodeFormatter??>${accountCodeFormatter.valueToString(glAccountInfo.accountCode)}<#else>${glAccountInfo.accountCode}</#if>: ${glAccountInfo.accountName}</td>
                <#if (timePeriodIdList?size > 1)>
                    <td class="text-right text-mono" style="padding-right:${depth+2}em;">${ec.l10n.format((glAccountInfo.postedNoClosingByTimePeriod['ALL']!0)*negMult, currencyFormat)}</td>
                </#if>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right text-mono" style="padding-right:${depth+2}em;">
                        <#if findEntryUrl??>
                            <#assign findEntryInstance = findEntryUrl.getInstance(sri, true).addParameter("glAccountId", glAccountInfo.glAccountId).addParameter("isPosted", "Y").addParameter("timePeriodId", timePeriodId)>
                            <a href="${findEntryInstance.getUrlWithParams()}">${ec.l10n.format((glAccountInfo.postedNoClosingByTimePeriod[timePeriodId]!0)*negMult, currencyFormat)}</a>
                        <#else>
                            ${ec.l10n.format((glAccountInfo.postedNoClosingByTimePeriod[timePeriodId]!0)*negMult, currencyFormat)}
                        </#if>
                    </td>
                    <#if showPercents>
                        <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                        <#assign currentAmt = (glAccountInfo.postedNoClosingByTimePeriod[timePeriodId]!0)*negMult>
                        <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                    </#if>
                </#list>
                <#if showDiff>
                    <td class="text-right text-mono" style="padding-right:${depth+2}em;">${ec.l10n.format(((glAccountInfo.postedNoClosingByTimePeriod[timePeriodIdList[1]]!0) - (glAccountInfo.postedNoClosingByTimePeriod[timePeriodIdList[0]]!0))*negMult, currencyFormat)}</td>
                </#if>
            </tr>
        <#else>
            <!-- ${glAccountInfo.accountCode}: ${glAccountInfo.accountName} ${glAccountInfo.postedNoClosingByTimePeriod} -->
        </#if>
    </#list>
    <#list classInfo.childClassInfoList as childClassInfo>
        <@showClass childClassInfo depth+1 showLess/>
    </#list>
    <#if classInfo.childClassInfoList?has_content>
        <tr<#if depth == 1> class="text-info"</#if>>
            <td style="padding-left: ${(depth-1) * 2}.3em;"><strong>${ec.l10n.localize(classInfo.className + " Total")}</strong><#if showLess && depth == 1> (${ec.l10n.localize("less")})</#if></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono" style="padding-right:${depth}em;"><strong>
                    ${ec.l10n.format((classInfo.totalPostedNoClosingByTimePeriod['ALL']!0)*negMult, currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono" style="padding-right:${depth}em;"><strong>
                    ${ec.l10n.format((classInfo.totalPostedNoClosingByTimePeriod[timePeriodId]!0)*negMult, currencyFormat)}</strong></td>
                <#if showPercents>
                    <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                    <#assign currentAmt = (classInfo.totalPostedNoClosingByTimePeriod[timePeriodId]!0)*negMult>
                    <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono" style="padding-right:${depth}em;"><strong>
                    ${ec.l10n.format(((classInfo.totalPostedNoClosingByTimePeriod[timePeriodIdList[1]]!0) - (classInfo.totalPostedNoClosingByTimePeriod[timePeriodIdList[0]]!0))*negMult, currencyFormat)}</strong></td>
            </#if>
        </tr>
    </#if>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Income Statement")}</th>
            <#if (timePeriodIdList?size > 1)><th class="text-right">${ec.l10n.localize("All Periods")}</th></#if>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName}</th>
                <#if showPercents><th class="text-right">${ec.l10n.localize("% of Revenue")}</th></#if>
            </#list>
            <#if showDiff><th class="text-right">${ec.l10n.localize("Difference")}</th></#if>
        </tr>
    </thead>
    <tbody>

        <@showClass classInfoById.REVENUE 1/>
        <@showClass classInfoById.CONTRA_REVENUE 1 true/>
        <tr class="text-success">
            <td><strong>${ec.l10n.localize("Net Revenue")}</strong> (${ec.l10n.localize("Revenue")} - ${ec.l10n.localize("Contra Revenue")})</td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono"><strong>${ec.l10n.format((classInfoById.REVENUE.totalPostedNoClosingByTimePeriod['ALL']!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod['ALL']!0), currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono"><strong>${ec.l10n.format((classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0), currencyFormat)}</strong></td>
                <#if showPercents>
                    <td class="text-right text-mono">${ec.l10n.format(1, percentFormat)}</td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono"><strong>${ec.l10n.format((classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodIdList[1]]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodIdList[1]]!0) - (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodIdList[0]]!0) - (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodIdList[0]]!0), currencyFormat)}</strong></td>
            </#if>
        </tr>

        <@showClass classInfoById.COST_OF_SALES 1 true/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Gross Profit On Sales")}</strong> (${ec.l10n.localize("Net Revenue")} - ${ec.l10n.localize("Cost of Sales")})</td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono"><strong>${ec.l10n.format(grossProfitOnSalesMap['ALL']!0, currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono"><strong>${ec.l10n.format(grossProfitOnSalesMap[timePeriodId]!0, currencyFormat)}</strong></td>
                <#if showPercents>
                    <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                    <#assign currentAmt = grossProfitOnSalesMap[timePeriodId]!0>
                    <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono"><strong>${ec.l10n.format((grossProfitOnSalesMap[timePeriodIdList[1]]!0) - (grossProfitOnSalesMap[timePeriodIdList[0]]!0), currencyFormat)}</strong></td>
            </#if>
        </tr>

        <@showClass classInfoById.EXPENSE 1 true/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Operating Income")}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netOperatingIncomeMap['ALL']!0, currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netOperatingIncomeMap[timePeriodId]!0, currencyFormat)}</strong></td>
                <#if showPercents>
                    <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                    <#assign currentAmt = netOperatingIncomeMap[timePeriodId]!0>
                    <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono"><strong>${ec.l10n.format((netOperatingIncomeMap[timePeriodIdList[1]]!0) - (netOperatingIncomeMap[timePeriodIdList[0]]!0), currencyFormat)}</strong></td>
            </#if>
        </tr>

        <@showClass classInfoById.INCOME 1/>
        <@showClass classInfoById.NON_OP_EXPENSE 1 true/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Non-operating Income")}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netNonOperatingIncomeMap['ALL']!0, currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netNonOperatingIncomeMap[timePeriodId]!0, currencyFormat)}</strong></td>
                <#if showPercents>
                    <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                    <#assign currentAmt = netNonOperatingIncomeMap[timePeriodId]!0>
                    <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono"><strong>${ec.l10n.format((netNonOperatingIncomeMap[timePeriodIdList[1]]!0) - (netNonOperatingIncomeMap[timePeriodIdList[0]]!0), currencyFormat)}</strong></td>
            </#if>
        </tr>

        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Income")}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netIncomeMap['ALL']!0, currencyFormat)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right text-mono"><strong>${ec.l10n.format(netIncomeMap[timePeriodId]!0, currencyFormat)}</strong></td>
                <#if showPercents>
                    <#assign netRevenueAmt = (classInfoById.REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedNoClosingByTimePeriod[timePeriodId]!0)>
                    <#assign currentAmt = netIncomeMap[timePeriodId]!0>
                    <td class="text-right text-mono"><#if netRevenueAmt != 0>${ec.l10n.format(currentAmt/netRevenueAmt, percentFormat)}</#if></td>
                </#if>
            </#list>
            <#if showDiff>
                <td class="text-right text-mono"><strong>${ec.l10n.format((netIncomeMap[timePeriodIdList[1]]!0) - (netIncomeMap[timePeriodIdList[0]]!0), currencyFormat)}</strong></td>
            </#if>
        </tr>
    </tbody>
</table>

<#if showCharts>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.6.0/Chart.min.js" type="text/javascript"></script>
    <ul class="float-plain" style="margin-top:12px;">
    <#if (timePeriodIdList?size > 1) && topExpenseByTimePeriod['ALL']?has_content>
        <#assign topExpenseList = topExpenseByTimePeriod['ALL']>
        <li>
            <div class="text-center"><strong>Expenses All Periods</strong></div>
            <canvas id="ExpenseChartAll" style="width:360px;"></canvas>
            <script>
                var expenseChartAll = new Chart(document.getElementById("ExpenseChartAll"), { type: 'pie',
                    data: { labels:[<#list topExpenseList! as topExpense>'${topExpense.className}'<#sep>,</#list>],
                        datasets:[{ data:[<#list topExpenseList! as topExpense>${topExpense.amount?c}<#sep>,</#list>],
                        backgroundColor:[<#list backgroundColors as color>'${color}'<#sep>,</#list>] }]
                    }
                });
            </script>
        </li>
    </#if>
    <#list timePeriodIdList as timePeriodId><#if topExpenseByTimePeriod[timePeriodId]?has_content>
        <#assign topExpenseList = topExpenseByTimePeriod[timePeriodId]>
        <li>
            <div class="text-center"><strong>Expenses ${timePeriodIdMap[timePeriodId].periodName}</strong></div>
            <canvas id="ExpenseChart${timePeriodId_index}" style="width:360px;"></canvas>
            <script>
                var expenseChartAll = new Chart(document.getElementById("ExpenseChart${timePeriodId_index}"), { type: 'pie',
                    data: { labels:[<#list topExpenseList! as topExpense>'${topExpense.className}'<#sep>,</#list>],
                        datasets:[{ data:[<#list topExpenseList! as topExpense>${topExpense.amount?c}<#sep>,</#list>],
                            backgroundColor:[<#list backgroundColors as color>'${color}'<#sep>,</#list>] }]
                    }
                });
            </script>
        </li>
    </#if></#list>
    </ul>
</#if>
