# -*- coding: utf-8 -*-
try:
    from setuptools import setup, find_packages
except ImportError:
    from ez_setup import use_setuptools
    use_setuptools()
    from setuptools import setup, find_packages

setup(
    name='convirt',
    version='2.0',
    description='',
    author='',
    author_email='',
    #url='',
    install_requires=[
                ],
    setup_requires=[],
    paster_plugins=[],
    packages=find_packages(exclude=['ez_setup']),
    include_package_data=True,
    test_suite='nose.collector',
    tests_require=[],
    package_data={'convirt': ['i18n/*/LC_MESSAGES/*.mo',
                                 'templates/*/*',
                                 'public/*/*']},
    message_extractors={'convirt': [
        ('**.py', 'python', None),
        #('templates/**.mako', 'mako', None),
        #('templates/**.html', 'genshi', None),
        ('public/javascript/*.js', 'javascript', None),
        ('public/**', 'ignore', None)]},

    entry_points="""
    [paste.app_factory]
    main = convirt.config.middleware:make_app

    [paste.app_install]
    main = pylons.util:PylonsInstaller
    """,
)
