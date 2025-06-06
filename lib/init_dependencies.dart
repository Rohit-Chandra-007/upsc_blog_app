import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:civilshots/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:civilshots/core/network/connection_checker.dart';
import 'package:civilshots/features/auth/domain/repository/auth_repository.dart';
import 'package:civilshots/features/auth/domain/usecases/current_user.dart';
import 'package:civilshots/features/auth/domain/usecases/user_sign_in.dart';
import 'package:civilshots/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:civilshots/features/blog/data/datasources/supabase_blog_remote_datasource.dart';
import 'package:civilshots/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:civilshots/features/blog/domain/usecases/fetch_all_blog.dart';
import 'package:civilshots/features/blog/domain/usecases/upload_blog.dart';

import 'features/auth/data/datasources/auth_supabase_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/user_sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/blog/domain/repository/blog_repository.dart';
import 'features/blog/presentation/bloc/blog_bloc.dart';

part 'init_dependencies.main.dart';

