# Artillery-LoadTesting
This repository has end to end solution for how to configure load test for your web application components.
<!-- wp:heading -->
<h2>Artillery Configuration</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul><li>In order to load test API, the first thing we need is a API :) For this Blog I am using free API from <a href="https://github.com/public-apis/">Github</a>.  I am using cats fact <a href="https://cat-fact.herokuapp.com/facts">API </a></li><li>Artillery needs a load test configuration file in YAML format. Detailed documentation for all the possible configurations are available <a href="https://artillery.io/docs/guides/guides/test-script-reference.html#Load-Phases">@link</a>. I am using some basic load configuration in YAML .</li></ul>
<!-- /wp:list -->

```
config:
    ensure:
      p95: 3000
    environments:
      local-dev:
        target: 'https://cat-fact.herokuapp.com/'
        phases:
        - name: "warm up"
          duration: 30
          arrivalRate: 5
          rampTo: 15     
scenarios:
    - name: "Staff APi"
      flow:
      - get:
          url: "/facts"
```          
<!-- wp:list -->
<ul><li>Core items in Yaml above are <ul><li>environment : we can configure more than one environment setting in one file and select which environment configuration we want to execute at runtime </li><li>duration: This will be the duration for load test</li><li>arrivalRate: This will be starting load when test starts</li><li>rampTo: This will be the max load for the durations</li></ul></li></ul>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>Artillery Execution Script</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul><li>Next we need a powershell script which we can use to trigger artillery load test by supplying the load test configuration yaml</li></ul>
<!-- /wp:list -->

<!-- wp:shortcode -->

```powershell
Write-Host "Invoking Artillery to run load test $env:LOAD_TEST_NAME with file $env:ARTILLERYIO_FILE"

$outputFile = "/tmp/$env:REPORT_NAME.json"
$resultsFile = "/tmp/$env:REPORT_NAME.html"

./node_modules/artillery/bin/artillery run $env:ARTILLERYIO_FILE -e $env:ARTILLERY_ENVIRONMENT -o $outputFile

Write-Host "Creating results file"

./node_modules/artillery/bin/artillery report -o $resultsFile $outputFile

Write-Host "Result created"
Write-Host "Read result"
$result = Get-Content -Path $outputFile  
Write-Host $result 
write-host "Finished load test"

exit

```

<!-- /wp:shortcode -->

<!-- wp:list -->
<ul><li>The code block above is the PS script which will be executer, once the container is initialized. I next step we will go through the docker file for the containerization. Some of the critical lines from code above is documented below:<ul><li><span style="color:#ff6900;" class="has-inline-color"><strong>Line 5 : </strong></span>Artillery provides a json output file which has all the results,  we are defining the file here.</li><li><span style="color:#ff6900;" class="has-inline-color"><strong>Line 6 : </strong></span>Json results are hard to read so artillery also provides a json transformation to html graphs which are easy to read. In this line we are defining the graphical html file</li><li><span style="color:#ff6900;" class="has-inline-color"><strong>Line 8 :</strong></span> In this line we are executing the artillery load test, as stated earlier in yaml explanation. We provide environment name from yaml file, output json file name and load test yaml configuration file details</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 10 : </span></strong>In this line we are transforming json result file to html graphical file</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 15 :</span></strong> In this line I am spitting the json test result as log. In production use case you make load the json &amp; html output file to some external storage like Azure Blob or AWS S3.</li></ul></li></ul>
<!-- /wp:list -->          