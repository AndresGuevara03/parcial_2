import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/establecimiento_model.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_error_view.dart';
import '../widgets/premium_background.dart';

class EstablecimientoFormView extends StatefulWidget {
  const EstablecimientoFormView({super.key, this.id});

  final int? id;

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _nitCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _logoUrl;
  File? _selectedImage;

  bool get _isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadDetail();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final item = await ApiService.instance.fetchEstablecimiento(widget.id!);
      if (!mounted) {
        return;
      }
      _fillFields(item);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No fue posible cargar el establecimiento.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fillFields(Establecimiento item) {
    setState(() {
      _nombreCtrl.text = item.nombre;
      _nitCtrl.text = item.nit;
      _direccionCtrl.text = item.direccion;
      _telefonoCtrl.text = item.telefono;
      _logoUrl = item.logo;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = File(file.path);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final data = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'nit': _nitCtrl.text.trim(),
        'direccion': _direccionCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
      };

      if (_selectedImage != null) {
        data['logo'] = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split(Platform.pathSeparator).last,
        );
      }

      final formData = FormData.fromMap(data);

      if (_isEdit) {
        await ApiService.instance.updateEstablecimiento(widget.id!, formData);
      } else {
        await ApiService.instance.createEstablecimiento(formData);
      }

      if (!mounted) {
        return;
      }
      context.pop(true);
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _extractApiError(
          e,
          fallback: 'No fue posible guardar el establecimiento.',
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No fue posible guardar el establecimiento.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar establecimiento'),
          content: const Text(
            'Esta accion no se puede deshacer. ¿Deseas continuar?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => context.pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ApiService.instance.deleteEstablecimiento(widget.id!);
      if (!mounted) {
        return;
      }
      context.pop(true);
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _extractApiError(
          e,
          fallback: 'No fue posible eliminar el establecimiento.',
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No fue posible eliminar el establecimiento.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Editar Establecimiento' : 'Crear Establecimiento';

    if (_error != null && _isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: AppErrorView(message: _error!, onRetry: _loadDetail),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title)),
      body: PremiumBackground(
        child: Skeletonizer(
          enabled: _isLoading,
          child: IgnorePointer(
            ignoring: _isSaving,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
              children: <Widget>[
                if (_error != null && !_isLoading) ...<Widget>[
                  Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 12),
                ],
                Center(child: _buildLogoPreview()),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Seleccionar logo'),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) => _required(value, 'nombre'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nitCtrl,
                        decoration: const InputDecoration(labelText: 'NIT'),
                        validator: (value) => _required(value, 'NIT'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _direccionCtrl,
                        decoration: const InputDecoration(labelText: 'Direccion'),
                        validator: (value) => _required(value, 'direccion'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telefonoCtrl,
                        decoration: const InputDecoration(labelText: 'Telefono'),
                        validator: (value) => _required(value, 'telefono'),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isEdit ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                      if (_isEdit) ...<Widget>[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _delete,
                            icon: const Icon(
                              Icons.delete,
                              color: AppTheme.accentColor,
                            ),
                            label: const Text(
                              'Eliminar',
                              style: TextStyle(color: AppTheme.accentColor),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    if ((_logoUrl ?? '').startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _logoUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholderLogo(),
        ),
      );
    }

    return _placeholderLogo();
  }

  Widget _placeholderLogo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppTheme.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: isDark ? AppTheme.primaryLight : AppTheme.secondaryColor,
      ),
    );
  }

  String? _required(String? value, String field) {
    if ((value ?? '').trim().isEmpty) {
      return 'Ingresa el $field';
    }
    return null;
  }

  String _extractApiError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        for (final entry in errors.entries) {
          final field = entry.key;
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            final first = value.first.toString().trim();
            if (first.isNotEmpty) {
              return '$field: $first';
            }
          }
          final text = value?.toString().trim() ?? '';
          if (text.isNotEmpty) {
            return '$field: $text';
          }
        }
      }

      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }
    final message = e.message;
    if (message != null && message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
