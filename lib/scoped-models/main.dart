import 'package:scoped_model/scoped_model.dart';
import './connected_pals.dart';

class MainModel extends Model
    with RefersModel, ConnectedPalsModel, UserModel, AlertsModel, UtilityModel {}
