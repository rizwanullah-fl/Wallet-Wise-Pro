
class Saloontrending {
  bool? success;
  List<Data>? data;

  Saloontrending({this.success, this.data});

  Saloontrending.fromJson(Map<String, dynamic> json) {
    if(json["success"] is bool) {
      success = json["success"];
    }
    if(json["data"] is List) {
      data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["success"] = success;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  int? id;
  int? userId;
  String? name;
  String? locationDetail;
  String? cover;
  String? videoPath;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? rating;
  int? ratingCount;
  List<Gallery>? gallery;
  List<Review>? review;
  List<Services>? services;

  Data({this.id, this.userId, this.name, this.locationDetail, this.cover, this.videoPath, this.description, this.createdAt, this.updatedAt, this.rating, this.ratingCount, this.gallery, this.review, this.services});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["user_id"] is int) {
      userId = json["user_id"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["location_detail"] is String) {
      locationDetail = json["location_detail"];
    }
    if(json["cover"] is String) {
      cover = json["cover"];
    }
    if(json["video_path"] is String) {
      videoPath = json["video_path"];
    }
    if(json["description"] is String) {
      description = json["description"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
    if(json["rating"] is int) {
      rating = json["rating"];
    }
    if(json["rating_count"] is int) {
      ratingCount = json["rating_count"];
    }
    if(json["gallery"] is List) {
      gallery = json["gallery"] == null ? null : (json["gallery"] as List).map((e) => Gallery.fromJson(e)).toList();
    }
    if(json["review"] is List) {
      review = json["review"] == null ? null : (json["review"] as List).map((e) => Review.fromJson(e)).toList();
    }
    if(json["services"] is List) {
      services = json["services"] == null ? null : (json["services"] as List).map((e) => Services.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["user_id"] = userId;
    _data["name"] = name;
    _data["location_detail"] = locationDetail;
    _data["cover"] = cover;
    _data["video_path"] = videoPath;
    _data["description"] = description;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    _data["rating"] = rating;
    _data["rating_count"] = ratingCount;
    if(gallery != null) {
      _data["gallery"] = gallery?.map((e) => e.toJson()).toList();
    }
    if(review != null) {
      _data["review"] = review?.map((e) => e.toJson()).toList();
    }
    if(services != null) {
      _data["services"] = services?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Services {
  int? id;
  String? name;
  String? logo;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Services({this.id, this.name, this.logo, this.description, this.status, this.createdAt, this.updatedAt, this.pivot});

  Services.fromJson(Map<String, dynamic> json) {
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["logo"] is String) {
      logo = json["logo"];
    }
    if(json["description"] is String) {
      description = json["description"];
    }
    if(json["status"] is String) {
      status = json["status"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
    if(json["pivot"] is Map) {
      pivot = json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["logo"] = logo;
    _data["description"] = description;
    _data["status"] = status;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    if(pivot != null) {
      _data["pivot"] = pivot?.toJson();
    }
    return _data;
  }
}

class Pivot {
  int? salonId;
  int? serviceId;
  String? price;

  Pivot({this.salonId, this.serviceId, this.price});

  Pivot.fromJson(Map<String, dynamic> json) {
    if(json["salon_id"] is int) {
      salonId = json["salon_id"];
    }
    if(json["service_id"] is int) {
      serviceId = json["service_id"];
    }
    if(json["price"] is String) {
      price = json["price"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["salon_id"] = salonId;
    _data["service_id"] = serviceId;
    _data["price"] = price;
    return _data;
  }
}

class Review {
  int? id;
  int? salonId;
  int? from;
  String? rating;
  String? review;
  String? createdAt;
  String? updatedAt;

  Review({this.id, this.salonId, this.from, this.rating, this.review, this.createdAt, this.updatedAt});

  Review.fromJson(Map<String, dynamic> json) {
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["salon_id"] is int) {
      salonId = json["salon_id"];
    }
    if(json["from"] is int) {
      from = json["from"];
    }
    if(json["rating"] is String) {
      rating = json["rating"];
    }
    if(json["review"] is String) {
      review = json["review"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["salon_id"] = salonId;
    _data["from"] = from;
    _data["rating"] = rating;
    _data["review"] = review;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}

class Gallery {
  int? id;
  int? salonId;
  String? image;
  String? createdAt;
  String? updatedAt;

  Gallery({this.id, this.salonId, this.image, this.createdAt, this.updatedAt});

  Gallery.fromJson(Map<String, dynamic> json) {
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["salon_id"] is int) {
      salonId = json["salon_id"];
    }
    if(json["image"] is String) {
      image = json["image"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["salon_id"] = salonId;
    _data["image"] = image;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}