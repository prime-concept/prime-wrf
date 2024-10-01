import UIKit

enum ApplicationAppearance {
    // MARK: - Color
    static let mainColor = UIColor(red: 0.251, green: 0.118, blue: 0.082, alpha: 1)

    // MARK: - Appearance

    static func appearance() -> ProfileView.Appearance {
        var appearance = ProfileView.Appearance()
        appearance.titleLabelTextColor = Self.mainColor
        appearance.tabBarTintColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ShadowViewControl.Appearance {
        var appearance = ShadowViewControl.Appearance()
        appearance.selectedBackgroundColor = UIColor(red: 0.784, green: 0.678, blue: 0.49, alpha: 1)
        return appearance
    }

    static func appearance() -> ShadowButton.Appearance {
        var appearance = ShadowButton.Appearance()
        appearance.mainTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> WRFBarButton.Appearance {
        var appearance = WRFBarButton.Appearance()
        appearance.tabBarTintColor = Self.mainColor
        appearance.tabBarButtonSelectedColor = Self.mainColor
        return appearance
    }

    static func appearance() -> SettingsItemView.Appearance {
        var appearance = SettingsItemView.Appearance()
        appearance.itemTitleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileSettingsView.Appearance {
        var appearance = ProfileSettingsView.Appearance()
        appearance.logoutButtonTextColor = UIColor(red: 0.833, green: 0.806, blue: 0.757, alpha: 1)
        return appearance
    }

    static func appearance() -> SimpleTextField.Appearance {
        var appearance = SimpleTextField.Appearance()
        appearance.fieldTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileFeedbackView.Appearance {
        var appearance = ProfileFeedbackView.Appearance()
        appearance.titleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileFeedbackTypeView.Appearance {
        var appearance = ProfileFeedbackTypeView.Appearance()
        appearance.titleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> GrowingTextView.Appearance {
        var appearance = GrowingTextView.Appearance()
        appearance.textColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileFaqTableViewCell.Appearance {
        var appearance = ProfileFaqTableViewCell.Appearance()
        appearance.titleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileAboutView.Appearance {
        var appearance = ProfileAboutView.Appearance()
        appearance.titleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantDescriptionView.Appearance {
        var appearance = RestaurantDescriptionView.Appearance()
        appearance.textColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileAboutVersionView.Appearance {
        var appearance = ProfileAboutVersionView.Appearance()
        appearance.versionColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileContactsItemView.Appearance {
        var appearance = ProfileContactsItemView.Appearance()
        appearance.valueColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileAboutServiceView.Appearance {
        var appearance = ProfileAboutServiceView.Appearance()
        appearance.titleColor = Self.mainColor
        appearance.descriptionColor = Self.mainColor
        return appearance
    }

    static func appearance() -> MapRestaurantItemView.Appearance {
        var appearance = MapRestaurantItemView.Appearance()
        appearance.timeTextColor = UIColor.white
        appearance.timeBackgroundColor = UIColor(red: 0.784, green: 0.678, blue: 0.49, alpha: 1)
        return appearance
    }

    static func appearance() -> MapButton.Appearance {
        var appearance = MapButton.Appearance()
        appearance.buttonColor = Self.mainColor
        return appearance
    }

    static func appearance() -> MapTagsCollectionViewCell.Appearance {
        var appearance = MapTagsCollectionViewCell.Appearance()
        appearance.shouldUseImageShadow = false
        return appearance
    }

    static func appearance() -> EmptyDataView.Appearance {
        var appearance = EmptyDataView.Appearance()
        appearance.titleColor = Self.mainColor
        return appearance
    }

    static func appearance() -> MyCardInfoView.Appearance {
        var appearance = MyCardInfoView.Appearance()
        appearance.descriptionLabelTextColor = Self.mainColor
        appearance.rulesLabelTextColor = Self.mainColor
        appearance.underlineColor = Self.mainColor
        appearance.cardHeaderHeight = 71
        appearance.cardHeaderLogoSize = CGSize(width: 73, height: 40)
        appearance.cardHeaderLogo = #imageLiteral(resourceName: "dark-logo")
        return appearance
    }

    static func appearance() -> MyCardInfoTypeView.Appearance {
        var appearance = MyCardInfoTypeView.Appearance()
        appearance.typeLabelTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> AuthView.Appearance {
        var appearance = AuthView.Appearance()
        appearance.logoSize = CGSize(width: 111, height: 60)
        return appearance
    }

    static func appearance() -> AuthConfirmationView.Appearance {
        var appearance = AuthConfirmationView.Appearance()
        appearance.logoSize = CGSize(width: 111, height: 60)
        appearance.titleTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileFaqDetailView.Appearance {
        var appearance = ProfileFaqDetailView.Appearance()
        appearance.titleColor = Self.mainColor
        appearance.textColor = Self.mainColor
        return appearance
    }

    static func appearance() -> MapFilterItemView.Appearance {
        var appearance = MapFilterItemView.Appearance()
        appearance.itemTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ProfileFeedbackCompletedActionView.Appearance {
        var appearance = ProfileFeedbackCompletedActionView.Appearance()
        appearance.titleColor = Self.mainColor
        appearance.buttonTitleTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> FeedbackView.Appearance {
        var appearance = FeedbackView.Appearance()
        appearance.confirmationButtonBackgroundColor = Self.mainColor
        return appearance
    }

    static func appearance() -> FeedbackRateView.Appearance {
        var appearance = FeedbackRateView.Appearance()
        appearance.titleTextColor = Self.mainColor
        appearance.starFilledColor = Self.mainColor
        appearance.starClearColor = UIColor(
            red: 0.867,
            green: 0.843,
            blue: 0.796,
            alpha: 1
        )
        return appearance
    }

    static func appearance() -> FeedbackTagsView.Appearance {
        var appearance = FeedbackTagsView.Appearance()
        appearance.titleTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> FeedbackAgreementView.Appearance {
        var appearance = FeedbackAgreementView.Appearance()
        appearance.titleTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> CheckboxControl.Appearance {
        var appearance = CheckboxControl.Appearance()
        appearance.selectedBackgroundColor = Self.mainColor
        return appearance
    }

    static func appearance() -> NotificationsItemView.Appearance {
        var appearance = NotificationsItemView.Appearance()
        appearance.messageColor = Self.mainColor
        return appearance
    }

    static func appearance() -> AuthConfirmationControlsView.Appearance {
        var appearance = AuthConfirmationControlsView.Appearance()
        appearance.shouldUsePrivacyPolicy = false
        return appearance
    }

    static func appearance() -> WRFTabBarController.Appearance {
        var appearance = WRFTabBarController.Appearance()
        appearance.mainTabImageInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        return appearance
    }

    static func appearance() -> RestaurantBookingStepper.Appearance {
        var appearance = RestaurantBookingStepper.Appearance()
        appearance.mainTextColor = Self.mainColor
        appearance.buttonTintColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingDayButton.Appearance {
        var appearance = RestaurantBookingDayButton.Appearance()
        appearance.mainTextColor = Self.mainColor
        appearance.mainSelectedTextColor = .white
        appearance.secondaryTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        appearance.secondarySelectedTextColor = .white
        appearance.selectedBackgroundColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingView.Appearance {
        var appearance = RestaurantBookingView.Appearance()
        appearance.calendarButtonTintColor = Self.mainColor
        appearance.commentPlaceholderColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        appearance.commentTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingTimePickerView.Appearance {
        var appearance = RestaurantBookingTimePickerView.Appearance()
        appearance.loadingColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        appearance.timeSelectedBackgroundColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingCheckoutAgreementView.Appearance {
        var appearance = RestaurantBookingCheckoutAgreementView.Appearance()
        appearance.agreementTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingResultView.Appearance {
        var appearance = RestaurantBookingResultView.Appearance()
        appearance.mainTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> ShadowIconButton.Appearance {
        var appearance = ShadowIconButton.Appearance()
        appearance.mainTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantBookingActionView.Appearance {
        var appearance = RestaurantBookingActionView.Appearance()
        appearance.buttonTitleTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantUnavailableView.Appearance {
        var appearance = RestaurantUnavailableView.Appearance()
        appearance.daysTextColor = Self.mainColor
        appearance.timeTextColor = Self.mainColor
        appearance.descriptionTextColor = Self.mainColor
        appearance.daysBackgroundColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        return appearance
    }

    static func appearance() -> RestaurantTagsView.Appearance {
        var appearance = RestaurantTagsView.Appearance()
        appearance.tagTextColor = Self.mainColor
        appearance.tagBackgroundColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        return appearance
    }

    static func appearance() -> RestaurantPhotosView.Appearance {
        var appearance = RestaurantPhotosView.Appearance()
        appearance.titleTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        return appearance
    }

    static func appearance() -> RestaurantEventsView.Appearance {
        var appearance = RestaurantEventsView.Appearance()
        appearance.titleTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        return appearance
    }

    static func appearance() -> RestaurantLocationView.Appearance {
        var appearance = RestaurantLocationView.Appearance()
        appearance.titleTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        appearance.locationTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantLikesView.Appearance {
        var appearance = RestaurantLikesView.Appearance()
        appearance.textColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantReviewsView.Appearance {
        var appearance = RestaurantReviewsView.Appearance()
        appearance.starColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        appearance.starFilledColor = Self.mainColor
        appearance.rateTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        appearance.countHightlightTextColor = Self.mainColor
        appearance.countTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        return appearance
    }

    static func appearance() -> RestaurantReviewItemView.Appearance {
        var appearance = RestaurantReviewItemView.Appearance()
        appearance.starColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        appearance.starFilledColor = Self.mainColor
        appearance.titleTextColor = Self.mainColor
        appearance.subtitleTextColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 1)
        appearance.backgroundColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        appearance.reviewTextColor = Self.mainColor
        return appearance
    }

    static func appearance() -> RestaurantContactsView.Appearance {
        var appearance = RestaurantContactsView.Appearance()
        appearance.contactButtonColor = Self.mainColor
        appearance.timeTextColor = Self.mainColor
        appearance.daysTextColor = Self.mainColor
        appearance.daysBackgroundColor = UIColor(red: 0.78, green: 0.737, blue: 0.659, alpha: 0.2)
        return appearance
    }

    static func appearance() -> AuthSignUpView.Appearance {
        var appearance = AuthSignUpView.Appearance()
        appearance.toolbarTintColor = Self.mainColor
        return appearance
    }

	static func appearance() -> CertificatesTabbedViewController.Appearance {
		.init()
	}

	static func appearance() -> CertificatesListViewController.Appearance {
		.init()
	}

	static func appearance() -> CertificateCellContentView.Appearance {
		.init()
	}

	static func appearance() -> CertificatesNavigationView.Appearance {
		.init()
	}

	static func appearance() -> CertificatesTabbedView.Appearance {
		.init()
	}

	static func appearance() -> CertificateDetailsViewController.Appearance {
		.init()
	}

	static func appearance() -> CertificateUsageView.Appearance {
		.init()
	}

	static func appearance() -> CertificatePurchaseView.Appearance {
		.init()
	}

	static func appearance() -> CertificateExpirationView.Appearance {
		.init()
	}

	static func appearance() -> CertificateDetailsHeaderView.Appearance {
		.init()
	}

	static func appearance() -> CertificateNotificationView.Appearance {
		.init()
	}
}
