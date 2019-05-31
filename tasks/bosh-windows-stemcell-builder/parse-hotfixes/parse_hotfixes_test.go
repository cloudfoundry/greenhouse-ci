package main_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "../parse-hotfixes"
)

var _ = Describe("ParseHotfixes", func() {
	Describe("ParseHotfix", func() {
		It("should print the output of the Get-Hotfix provisioner block", func() {
			actualHotfixes, err := ParseHotfix()
			expectHotfixes := "idk yet?"

			Expect(err).NotTo(HaveOccurred())
			Expect(actualHotfixes).To(Equal(expectHotfixes))
		})
	})
})
