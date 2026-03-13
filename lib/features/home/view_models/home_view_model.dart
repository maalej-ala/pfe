import '../models/step_model.dart';

class HomeViewModel {

 List<StepModel> steps = [
  StepModel(label: "Identification", number: "1"),
  StepModel(label: "Adresse", number: "2"),
  StepModel(label: "Situation personnelle", number: "3"),
  StepModel(label: "Situation professionnelle", number: "4"),
  StepModel(label: "Choix bancaire", number: "5"),
  StepModel(label: "Vérification identité", number: "6"),
  StepModel(label: "Mot de passe", number: "7"),
  StepModel(label: "Signature", number: "8"),
];
}