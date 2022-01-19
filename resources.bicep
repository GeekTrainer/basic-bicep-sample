param basename string
param location string

resource web 'Microsoft.Web/sites@2021-01-15' = {
  name: '${basename}web'
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: farm.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
      alwaysOn: true
      ftpsState: 'FtpsOnly'
      // appCommandLine: 'pm2 serve /home/site/wwwroot --no-daemon --spa'
    }
    httpsOnly: true
  }

  resource webappappsettings 'config' = {
    name: 'appsettings'
    properties: {
      'APPINSIGHTS_INSTRUMENTATIONKEY': cosmos.listConnectionStrings().connectionStrings[0].connectionString
    }
  }
}

resource farm 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: '${basename}farm'
  location: location
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: '${basename}-cosmos'
  kind: 'MongoDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    apiProperties: {
      serverVersion: '4.0'
    }
    databaseAccountOfferType: 'Standard'
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}
