# Automation-Scripts

## 1. Disk Usage Monitor Script
### Overview
#### The Disk Usage Monitor script collects disk usage information and presents it in a visually appealing format with a bar graph display for each partition. This tool is useful for quickly assessing disk space usage across all partitions.

### Steps and Solution Explanation
#### Collect Disk Usage Data: 
The script runs ```bash df -h ``` to gather disk usage information for each partition. The -h flag provides the output in a human-readable format.

#### Parse and Format Output: 
The output is processed to extract each partition's name, usage, and percentage. This ensures that all necessary details are included in the final output.

#### Visual Representation with Bar Graph: 
Each partition's usage percentage is displayed as a color-coded bar graph in the terminal, making it easy to identify high-usage areas at a glance. Spaces and formatting improvements are added for a more professional look.

#### Display Results: 
The formatted data and graphs are then printed to the terminal, offering a comprehensive view of the disk usage across partitions.
