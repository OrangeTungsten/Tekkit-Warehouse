# Tekkit Warehouse

This repository contains a Lua-based [ComputerCraft](https://tekkitclassic.fandom.com/wiki/Category:ComputerCraft) application for [Tekkit Classic](https://tekkitclassic.fandom.com/wiki/The_Tekkit_Wiki), acting as a fully integrated warehouse management and export system. It monitors in-game resources using the [ccSensors](https://tekkitclassic.fandom.com/wiki/Category:CcSensors) API to track chest inventories, and controls [RedPower2](https://tekkitclassic.fandom.com/wiki/Category:RedPower2) hardware to automate item extraction.

<img width="411" height="237" alt="Temrinal" src="https://github.com/user-attachments/assets/a5fd41ea-99a6-4e57-85bf-163756ee1121" />

# Project Overview
The application provides a Graphical User Interface (GUI) to monitor stock levels and Equivalent Exchange (EMC) values across a storage facility. 

Each item type is sorted into its own dedicated chest. The system logs totals, but also acts as an active controller for items extrction. By selecting an item and specifying a quantity, the program triggers specific RedPower2 filters with appropriate number of pulses, beneath  to extract the exact amount requested.

# Key Features & Technical Details
- CC Sensors Sensor Integration: The system polls inventory data using the ccSensors API, gathering metrics across multiple distinct physical sensors to monitor separate chests. 
- Hardware Actuation: Automated extraction is handled via bundled redstone cables combined with Insulated wires (16 colors available), where each of the chest (item type) is mapped to a specific wire color.
- Filter Synchronization: To ensure smooth interaction with the in-game extraction filters, the application validates user input.
- Interactive GUI & Pagination: The interface supports keyboard navigation (UP, DOWN) and dynamic pagination (PGUP, PGDOWN), displaying up to 10 items per page. The END button triggers immediate application termination.
- Economic Tracking: The software calculates and displays both the total EMC value of the current inventory and the cumulative EMC value of all shipped items.
- Pulse-Width Exporting: When an export is confirmed, the system generates controlled redstone pulses (0.25s intervals) to safely trigger the physical filters without lagging. 

# How to install it?
Just copy content from WAREHOUSE.lua to the blank app created on your CC Computer. 

You also can copy a WAREHOUSE.lua file to of your CC Computer storage which could be found on: `%appdata%tekkit_root/computer/num_of_your_comp`, but in that case, .lua extension should be removed.

# Preview
<img width="1550" height="800" alt="2026-04-23_18 26 30" src="https://github.com/user-attachments/assets/d7ef8ff4-f7d2-4c14-b476-d8e3c3a91413" />
