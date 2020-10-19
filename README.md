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
<!-- wp:heading -->
<h2>Artillery Containerization</h2>
<!-- /wp:heading -->

<!-- wp:image {"align":"left","id":4731,"width":223,"height":130,"sizeSlug":"large","linkDestination":"media"} -->
<div class="wp-block-image"><figure class="alignleft size-large is-resized"><a href="https://khanasif1.files.wordpress.com/2020/10/aks.png"><img src="https://khanasif1.files.wordpress.com/2020/10/aks.png?w=400" alt="" class="wp-image-4731" width="223" height="130"/></a></figure></div>
<!-- /wp:image -->

<!-- wp:image {"align":"left","id":4732,"width":223,"height":134,"sizeSlug":"large","linkDestination":"media"} -->
<div class="wp-block-image"><figure class="alignleft size-large is-resized"><a href="https://khanasif1.files.wordpress.com/2020/10/eks-2.png"><img src="https://khanasif1.files.wordpress.com/2020/10/eks-2.png?w=251" alt="" class="wp-image-4732" width="223" height="134"/></a></figure></div>
<!-- /wp:image -->

<!-- wp:image {"align":"left","id":4737,"width":214,"height":108,"sizeSlug":"large","linkDestination":"media"} -->
<div class="wp-block-image"><figure class="alignleft size-large is-resized"><a href="https://khanasif1.files.wordpress.com/2020/10/swarm.png"><img src="https://khanasif1.files.wordpress.com/2020/10/swarm.png?w=316" alt="" class="wp-image-4737" width="214" height="108"/></a></figure></div>
<!-- /wp:image -->

<!-- wp:image {"align":"left","id":4733,"width":259,"height":115,"sizeSlug":"large","linkDestination":"media"} -->
<div class="wp-block-image"><figure class="alignleft size-large is-resized"><a href="https://khanasif1.files.wordpress.com/2020/10/gke.png"><img src="https://khanasif1.files.wordpress.com/2020/10/gke.png?w=339" alt="" class="wp-image-4733" width="259" height="115"/></a></figure></div>
<!-- /wp:image -->

<!-- wp:shortcode -->

'``

# FROM node:8-alpine
FROM mcr.microsoft.com/powershell:6.2.1-alpine-3.8

WORKDIR /app

RUN apk add --update nodejs nodejs-npm
SHELL [ "pwsh", "--Command" ]

COPY ./package.json /app

# Restore the NPM packages
RUN ["npm", "install"]

# RUN pwsh -c Install-Module -Name Az -AllowClobber -Force

# COPY ./artifacts/ .
COPY ./aci_script/ .

# Build time argument
ARG ARTILLERY_ENVIRONMENT='local-dev'
ARG RESULTS_FILE_SHARE=.
ARG REPORT_NAME=report
ARG ARTILLERYIO_FILE=./load.yml 

# Run time argument, default to the build time argument
ENV ARTILLERY_ENVIRONMENT='local-dev'
ENV RESULTS_FILE_SHARE=$RESULTS_FILE_SHARE
ENV REPORT_NAME=$REPORT_NAME
ENV ARTILLERYIO_FILE=$ARTILLERYIO_FILE
ENV AZ_STORAGE_ACCOUNT=''
ENV AZ_STORAGE_KEY=''
ENV LOAD_TEST_NAME=''

ENTRYPOINT [ "pwsh", "run-load-test.ps1" ]

```

<!-- /wp:shortcode -->

<!-- wp:paragraph -->
<p>Last part is containerization of environment so that we can run it anywhere including popular containerization orchestration services like AKS, EKS, GKS</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 2:</span></strong> Docker image for this setup is build on Linux alpine with Powershell mcr.microsoft.com/powershell:6.2.1-alpine-3.8</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 6,7 : </span></strong>Update nodejs</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 11,12:</span></strong> Install all packages from package.json this will install artillery</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Lin 19 to 32: </span></strong>Variables for the execution</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 34:</span></strong> Invoke the run load test file we discussed in Artillery Execution Script section</li></ul>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>Build &amp; Run Container </h2>
<!-- /wp:heading -->

<!-- wp:shortcode -->

```powershell

#***********************
#****Build Image********
#***********************

docker build -t artillery-aci:latest .


#***********************
#******RUN Image********
#***********************

docker run -d --name artilleryloadtest artillery-aci:latest


#***********************
#****Get Container Log**
#***********************

docker logs --details  artilleryloadtest


#***********************
#****Cleanup container**
#***********************


docker rm artilleryloadtest -f
docker rmi artillery-aci:latest -f

```

<!-- /wp:shortcode -->

<!-- wp:list -->
<ul><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 5 :</span></strong> Build the container, using Dockerfile</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 12 :</span></strong> Run container, this will start the load test</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 19 :</span></strong> Artillery Execution script line 15 spits the json result, using docker log you can check the json result</li><li><strong><span style="color:#ff6900;" class="has-inline-color">Line 27,28: </span></strong>In order to build and redeploy the container run the script to remove any running container and then remove the image</li></ul>
<!-- /wp:list -->