// A monthly budget with alerts for one subscription, so a forgotten environment can't run up a bill unnoticed.
//   az deployment sub create -l westeurope -f budget.bicep -p amount=2000 contactEmails='["ops@example.com"]'
targetScope = 'subscription'

@description('Monthly budget in the billing currency')
param amount int

@description('Who gets the alerts')
param contactEmails array

@description('First day of the current month, yyyy-MM-01. Budgets must start on the first of a month.')
param startDate string = '${utcNow('yyyy-MM')}-01'

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: 'budget-monthly'
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      actual80: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: contactEmails
      }
      forecast100: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        thresholdType: 'Forecasted'
        contactEmails: contactEmails
      }
    }
  }
}
