class RequestModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String status;
  final String priority;
  final String date;
  RequestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.priority,
    required this.date,
  });
}

final List<RequestModel> requestList = [
  RequestModel(
    id: "REQ-2024-1058",
    title: "Classroom Fan Not Working",
    category: "Electricity",
    location: "Block A - 203",
    status: "In Progress",
    priority: "High",
    date: "12 May, 10:30 AM",
  ),
  RequestModel(
    id: "REQ-2024-1057",
    title: "Hostel Water Issue",
    category: "Plumbing",
    location: "Hostel C - 2",
    status: "Under Review",
    priority: "Medium",
    date: "12 May, 09:15 AM",
  ),
  RequestModel(
    id: "REQ-2024-1056",
    title: "WiFi Not Working",
    category: "Internet",
    location: "Library",
    status: "In Progress",
    priority: "High",
    date: "12 May, 08:45 AM",
  ),
  RequestModel(
    id: "REQ-2024-1055",
    title: "Broken Chair in Lab",
    category: "Maintenance",
    location: "Lab 1",
    status: "Submitted",
    priority: "Low",
    date: "11 May, 03:20 PM",
  ),
  RequestModel(
    id: "REQ-2024-1054",
    title: "Washroom Cleaning",
    category: "Cleaning",
    location: "Block B",
    status: "Resolved",
    priority: "Medium",
    date: "11 May, 02:10 PM",
  ),
  RequestModel(
    id: "REQ-2024-1053",
    title: "Projector Display Flickering",
    category: "Electricity",
    location: "Auditorium",
    status: "In Progress",
    priority: "High",
    date: "11 May, 11:30 AM",
  ),
  RequestModel(
    id: "REQ-2024-1052",
    title: "AC Remote Missing",
    category: "Maintenance",
    location: "Faculty Room 3",
    status: "Submitted",
    priority: "Low",
    date: "10 May, 04:00 PM",
  ),
  RequestModel(
    id: "REQ-2024-1051",
    title: "Water Dispenser Filter Change",
    category: "Plumbing",
    location: "Block C - 1st Floor",
    status: "Resolved",
    priority: "Medium",
    date: "10 May, 01:15 PM",
  ),
  RequestModel(
    id: "REQ-2024-1050",
    title: "Ethernet Port Not Working",
    category: "Internet",
    location: "Lab 4 - PC 12",
    status: "Under Review",
    priority: "High",
    date: "09 May, 05:40 PM",
  ),
  RequestModel(
    id: "REQ-2024-1049",
    title: "Whiteboard Marker & Duster Need",
    category: "Supplies",
    location: "Block A - 105",
    status: "Resolved",
    priority: "Low",
    date: "09 May, 10:00 AM",
  ),
];
