import "package:flutter/material.dart";

IconData categoryIcon(String? categoryName) {
  switch (categoryName) {
    case "Documents":
      return Icons.description_outlined;
    case "Reçus":
      return Icons.receipt_long_outlined;
    case "Garanties":
      return Icons.verified_user_outlined;
    case "Billets":
      return Icons.confirmation_number_outlined;
    case "Notes":
      return Icons.note_outlined;
    default:
      return Icons.folder_outlined;
  }
}
