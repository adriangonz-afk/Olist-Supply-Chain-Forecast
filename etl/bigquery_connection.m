let

  Source = GoogleBigQuery.Database([BillingProject = null, UseStorageApi = null, ConnectionTimeout = null, CommandTimeout = null, ProjectId = null]),

  #"Navigation 1" = Source{[Name = "proyecto-brazilian-e-commerce"]}[Data],

  #"Navigation 2" = #"Navigation 1"{[Name = "Supply_Chain_Analytics", Kind = "Schema"]}[Data],

  #"Navigation 3" = #"Navigation 2"{[Name = "hechos_logistica", Kind = "Table"]}[Data]

in

  #"Navigation 3"



let

  Source = GoogleBigQuery.Database([BillingProject = null, UseStorageApi = null, ConnectionTimeout = null, CommandTimeout = null, ProjectId = null]),

  #"Navigation 1" = Source{[Name = "proyecto-brazilian-e-commerce"]}[Data],
