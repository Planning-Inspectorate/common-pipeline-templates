import {describe, it} from 'node:test';
import * as assert from "node:assert";
import {parseCliResults} from "./impl.js";

describe('checkov-comments', () => {
    describe('parseCliResults', () => {
        it('should parse results and skip duplicates', () => {
            const results =  `Check: CKV2_AZURE_54: "Ensure log monitoring is enabled for Synapse SQL Pool"
        FAILED for resource: module.synapse_workspace_private_failover.azurerm_synapse_sql_pool.synapse
        File: /modules/synapse-workspace-private/synapse-sql-pool.tf:1-12
        Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/azure-policies/azure-logging-policies/bc-azure-2-54

                1  | resource "azurerm_synapse_sql_pool" "synapse" {
                2  |   count = var.sql_pool_enabled ? 1 : 0
                3  |
                4  |   name                 = "pinssyndpodw"
                5  |   synapse_workspace_id = azurerm_synapse_workspace.synapse.id
                6  |   sku_name             = var.sql_pool_sku_name
                7  |   collation            = var.sql_pool_collation
                8  |   create_mode          = "Default"
                9  |   storage_account_type = "GRS"
                10 |
                11 |   tags = local.tags
                12 | }

Check: CKV2_AZURE_51: "Ensure Synapse SQL Pool has a security alert policy"
        FAILED for resource: module.synapse_workspace_private.azurerm_synapse_sql_pool.synapse
        File: /modules/synapse-workspace-private/synapse-sql-pool.tf:1-12
        Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/azure-policies/azure-general-policies/bc-azure-2-51

                1  | resource "azurerm_synapse_sql_pool" "synapse" {
                10 |
                11 |   tags = local.tags
                12 | }

Check: CKV2_AZURE_51: "Ensure Synapse SQL Pool has a security alert policy"
        FAILED for resource: module.synapse_workspace_private_failover.azurerm_synapse_sql_pool.synapse
        File: /modules/synapse-workspace-private/synapse-sql-pool.tf:1-12
        Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/azure-policies/azure-general-policies/bc-azure-2-51

                1  | resource "azurerm_synapse_sql_pool" "synapse" {
                2  |   count = var.sql_pool_enabled ? 1 : 0
                3  |
                4  |   name                 = "pinssyndpodw"
                5  |   synapse_workspace_id = azurerm_synapse_workspace.synapse.id
                6  |   sku_name             = var.sql_pool_sku_name
                7  |   collation            = var.sql_pool_collation
                8  |   create_mode          = "Default"
                9  |   storage_account_type = "GRS"
                10 |
                11 |   tags = local.tags
                12 | }
`;
            const parsed = parseCliResults(results);
            assert.deepStrictEqual(parsed, [
                {
                    checkId: 'CKV2_AZURE_54',
                    checkDescription: 'Ensure log monitoring is enabled for Synapse SQL Pool',
                    filePath: '/modules/synapse-workspace-private/synapse-sql-pool.tf',
                    fileLines: ['1', '12']
                },
                {
                    checkId: 'CKV2_AZURE_51',
                    checkDescription: 'Ensure Synapse SQL Pool has a security alert policy',
                    filePath: '/modules/synapse-workspace-private/synapse-sql-pool.tf',
                    fileLines: ['1', '12']
                },
            ]);
        });
    });
});