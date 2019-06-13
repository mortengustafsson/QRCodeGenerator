//
//  ViewController.swift
//  QRGenerator
//
//  Created by Morten Gustafsson on 6/12/19.
//  Copyright © 2019 mortengustafsson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let textField = UITextField()
    private let button = UIButton(type: .custom)
    private let preview = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews(){
        view.backgroundColor = .white

        textField.placeholder = "Input your text"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.clearButtonMode = .whileEditing

        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitle("Generate", for: .normal)
        button.addTarget(self, action: #selector(generateQRCode), for: .touchUpInside)

        preview.backgroundColor = .lightGray

        let tap = UITapGestureRecognizer(target: self, action:  #selector(didTapPreview))
        preview.addGestureRecognizer(tap)
        preview.isUserInteractionEnabled = true

        view.addSubview(textField)
        view.addSubview(button)
        view.addSubview(preview)
    }

    private func setupConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        preview.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.TextField.topInset),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(Constants.TextField.leadingInset + Constants.TextField.trailingInset)),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Constants.Button.topInset),
            button.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: textField.trailingAnchor),

            preview.topAnchor.constraint(equalTo: button.bottomAnchor, constant: Constants.Preview.topInset),
            preview.widthAnchor.constraint(equalTo: textField.widthAnchor),
            preview.heightAnchor.constraint(equalTo: preview.widthAnchor),
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }

    @objc private func generateQRCode() {
        guard let customText = textField.text else { return }
        let qrImage = QRGeneratorService.convertTextToQRCode(text: customText, withSize: CGSize(width: 1024, height: 1024))
        preview.image = qrImage
    }

    @objc private func didTapPreview() {
        guard preview.image != nil else { return }
        showOptionMenu()
    }

    @objc private func showOptionMenu() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.saveImageToPhotoAlbum()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }

    @objc private func saveImageToPhotoAlbum() {
        guard let image = preview.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}

extension ViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        preview.image = nil
        return true
    }
}

extension ViewController {
    enum Constants {
            enum TextField {
                static let topInset: CGFloat = 40
                static let leadingInset: CGFloat = 20
                static let trailingInset: CGFloat = 20
            }

            enum Button {
                static let topInset: CGFloat = 20
            }

            enum Preview {
                static let topInset: CGFloat = 40
        }
    }
}
