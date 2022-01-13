# DEPRECATED

**This project is deprecated.**

----

## Introduction
Documentation for the basic usage of the Docker-ized OpenWayback image / container prepared by
the LOCKSS Program at Stanford University. It is based on CentOS 7.x and comes preconfigured 
with OpenWayback 2.3.0, OpenJDK 7, and Tomcat 8.x.

This document assumes some familiarity with Docker.

## Building the Docker image
To get up and running quickly, check out the prebuilt image in [our Docker Hub repository](https://hub.docker.com/r/lockss/openwayback/).

For development, we highly recommend building your own image:

1. Clone the Git repository for the latest source files:

    ```
    git clone https://github.com/lockss/openwayback-docker.git
    ```

2. Drop into the directory containing the `Dockerfile` and run the following command:

    ```
    docker build -t lockss/openwayback .
    ```

The name of the image can be changed from `lockss/openwayback` if desired.

## Basic Usage (with BDB Index)

1. Stage your ARC/WARC files (they may be gzipped to save space) into a path somewhere on your
filesystem. E.g.,

    ```shell
    mkdir -p /srv/openwayback/{arc,warc}
    ```

2. Start the Docker container by using `docker run lockss/openwayback` with the following parameters:
  * `-i -t` (Starts an interactive terminal.)
  * `--rm` (Docker will automatically remove the container, once the internal process has exited.)
  * `-p 8080:8080` (Forwards port localhost:8080 to port 8080 within the container; this port is
used to access the OpenWayback replay UI. If there is a conflict with an existing service on your 
machine, feel free to change the port number.)
  * `-v /srv/openwayback:/srv/openwayback` (Maps `/srv/openwayback` on the host machine to 
`/srv/openwayback` within the container. The path you map should point to the base directory path
where ARC/WARC files were staged in Step 1 (e.g. `/srv/openwayback`).

   Here is a complete example:

    ```shell
    docker run -i -t --rm -p 8080:8080 -v /srv/openwayback:/srv/openwayback lockss/openwayback
    ```

3. Finally, point your web browser to [http://localhost:8080/wayback/](http://localhost:8080/wayback/)
to begin using OpenWayback.
   **Note:** The base URL OpenWayback uses for link rewriting is specified by `wayback.url.prefix`
   in `wayback.xml`. If this change needs to be persistent, see the notes in the next section
   about creating a new image.

## CDX Index

CDX indexing is recommended by the OpenWayback team for any production or large scale use cases. In
depth documentation on CDX indexing is available from the [OpenWayback wiki](https://github.com/iipc/openwayback/wiki/How-to-configure)
but the big picture is as follows:

1. Creating the CDX index: Feed one or more ARC/WARC files through the OpenWayback `cdx-index` tool 
(not included in the Docker container; this tool is found in the official [OpenWayback .tar.gz package](http://search.maven.org/#browse%7C951206516).
2. Sort the CDX index (using the `sort` command under Linux/*BSD)
3. Create a path index which contains the paths of the actual location of the ARC/WARC files 
referenced in the CDX index. The URI can be a local filesystem path, HTTP, S3 or HDFS.
4. Modify the `wayback.xml` configuration file to use CDX index and point to the CDX index file 
and path index file created earlier.

This image *does not* support CDX indexing out of the box! Nor are configuration changes within a 
launched container persistent across instances of the image. If you plan to run OpenWayback within 
Docker containers using CDX indexing, I highly recommend creating a new image either by modifying
the Dockerfile and building a new image, or by making an image out of an existing Docker container,
contain your changes.  

It is worth noting that OpenWayback's preferred method for the installation of configuration files is by 
preparing and using an [OpenWayback WAR overlay](https://github.com/iipc/openwayback/wiki/Creating-a-WAR-overlay),
which is unpacked (along with the base OpenWayback WAR) when the Tomcat servlet container starts.
We do not make use of a WAR overlay yet.

## Support
Limited support is available by contacting LOCKSS Support at support@lockss.org.

## Resources
* OpenWayback wiki: https://github.com/iipc/openwayback/wiki
* OpenWayback binary downloads: http://search.maven.org/#browse%7C951206516
* Docker documentation: https://docs.docker.com/
